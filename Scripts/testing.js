db.jsenators.updateMany({}, {
    $set: {
    ;;    "allLinks.$[]._id": new ObjectId()
    }
})

db.people.aggregate([{
    $project: {
        _id: 0,
        gender: 1,
        fullName: {
            $concat: [
                { $toUpper: { $substrCP: ['$name.first', 0, 1] }},
                " ",
                { $toUpper: "$name.last"}
            ]
        }
    }
}]);


db.persons.aggregate([
  { $project: {
    _id: 0,
    name: 1,
    email: 1,
    gender: 1,
    dob: 1,
    location: {
      type: 'Point',
      coordinates: [
        { $convert: { input: "$location.coordinates.longitude", to: "decimal", onError: 0.0, onNull: 0.0 }},
        { $convert: { input: "$location.coordinates.latitude", to: "decimal", onError: 0.0, onNull: 0.0 }},
      ]
    }
  }},
  { $project: {
      email: 1,
      gender: 1,
      location: 1,
      birthDate: { $convert: { input: "$dob.date", to: "date" }},
      age: {$convert: { input: "$dob.age", to: "int" }},
      fullName: {
          $concat: [
              { $toUpper: { $substrCP: ['$name.first', 0, 1] }},
              { $substrCP: ['$name.first', 1, { $subtract: [{$strLenCP: "name.first"}, 1 ]}]},
              " ",
              { $toUpper: { $substrCP: ['$name.last', 0, 1] }},
              { $substrCP: ['$name.last', 1, { $subtract: [{$strLenCP: "name.last"}, 1 ]}]},
          ]
      }
  }},
  {
    $group: {
      _id: { birthYear: { $isoWeekYear: "$birthDate" }},
      numPersons: { $sum: 1 }
    }
  },
  {
    $sort: { "numPersons" : -1 }
  }
]).pretty();

// Find only persons older than 50
// Group them by gender
// Find out how many persons per gender
// Find the average age
// Order the output by the total persons per gender

// Output should have two genders w/ summary stats on # of persons older than 50, and average age.

db.people.aggregate([
  {
    $match: {
      "dob.age": { $gt: 50 }
    }
  },
  {
    $group: {
      _id: "$gender",
      total: { $sum: 1 },
      avgAge: { $avg: "$dob.age" }
    }
  },
  {
    "$sort": {
      "total": -1
    }
  }
])

db.friends.aggregate([
  {
    $unwind: "$hobbies" //
  },
  {
    $group: {
      _id: { age: "$age" },
      allHobbies: { $push: "$hobbies" } // Push a new element into the allHobbies array for every incoming document.
    },
  }
])

    db.friends.aggregate([
        {
        $unwind: "$examScores" // Expands an array and creates a new document for each item in the array, copying the rest of the data from the document.
        },
        {
        $group: {
            _id: "$_id",
            scores: { $push: "$examScores" }, // Push a new element into the allHobbies array for every incoming document.
            team: { $addToSet: "$name" }
        },
        }
    ]).pretty()

    db.friends.aggregate([
        {
            $project: {
                _id: 0,
                examScore: { $slice: ["$examScores", 1 ] } // Slice pulls off the number of items, starting from indexed 0. Negative numbers start from the back.
            }
        }
    ])

    db.friends.aggregate([
        {
            $project: {
                _id: 0,
                examScore: { $slice: ["$examScores", 1,3] } // Used with an array, the $slice operator skips the first number of itmes (1) and limits the result to the second number (3).
            }
        }
    ])

    db.books.aggregate([
        {
            $project: {
                numAuthors: { $size: "$authors" },
                pageCount: 1,
                title: 1,
                publishedDate: { $convert: { input: "$publishedDate", to: "string" }}
            }
        },
        {
            $group: {
                _id: { length:}
            }
        }
    ])

/// Find by search params...

const {
    minDate,
    maxDate,
    filter,  // Text to search
    filterTarget, // Row to search for text
    sortBy, // Row to sort by
    sortOrder, // 1 or -1
    skip, // rowsPerPage * pageNumber
    rowsPerPage, // Limit value
} = req.query;

let filter = 'M';
let filterTarget = 'registrant';
let searchTerm = { $regex: filter, $options: "i" };
let minDate = 0;
let maxDate = 2000000000000;
let sortBy = 'date';
let sortOrder = -1;
let rowsPerPage = 5;
let pageNumber = 0
let skip = rowsPerPage * pageNumber;
let source = 'fara';

db[source].aggregate([
        {
            $match: {
                date: {
                    $gt: minDate, // Filter out by time frame...
                    $lt: maxDate
                }
            }
        },
        {
            $match: {
                [filterTarget]: searchTerm // Match search query....
            }
        },
        {
            $set: {
                [filterTarget]: { $toLower: `$${filterTarget}` } // Necessary to ensure that sort works properly...
            }
        },
        {
            $sort: {
                [sortBy]: sortOrder // Sort by date...
            }
        },
        {
            $group: {
                _id: null,
                data: { $push: "$$ROOT" }, // Push each document into the data array.
                count: { $sum: 1 }
            }
        },
        {
            $project: {
                _id: 0,
                count: 1,
                data: {
                    $slice: ["$data", skip, rowsPerPage]
                },

            }
        }
]).pretty()



db.senators.aggregate([
    {
        $group: {
            _id: { "first": "$first" }
        }
    }
])

db.students.aggregate([
    {
        $unwind: "$examScores"
    },
    {
        $project: {
            _id: 1, name: 1, hobbies:1, age: 1, score: "$examScores.score"
        }
    },
    {
        $sort: { score: -1 }
    },
    {
        $group: {
            _id: "$_id",
            maxScore: { $max: "$score" },
            hobbies: { $first: "$hobbies" },
            name: { $first: "$name" },
        }
    },
    {
        $sort: { maxScore: -1 }
    }
])

db.persons.aggregate([
    {
        $bucket: {
            groupBy: "$dob.age",
            boundaries: [0, 18, 30, 50, 80, 120],
            output: {
                numPersons: { $sum: 1 },
                averageAge: { $avg: "$dob.age" },
                // names: { $push: "$name" }
            }
        }
    }
])

db.persons.aggregate([
    {
        $bucketAuto: {
            groupBy: "$dob.age",
            buckets: 5,
            output: {
                numPersons: { $sum: 1 },
                averageAge: { $avg: "$dob.age" },
            }
        }
    }
]);

db.persons.aggregate([
    {
        $project: {
            _id: 0,
            name: 1,
            birthdate: { $toDate: "$dob.date" }
        }
    },
    {
        $sort: { birthdate: 1 }
    },
    {
        $limit: 10
    },


])
