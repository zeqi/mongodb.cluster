MongoDB README

COMPONENTS

  bin/mongod - The database process.
  bin/mongos - Sharding controller.
  bin/mongo  - The database shell (uses interactive javascript).

UTILITIES

  bin/mongodump         - MongoDB dump tool - for backups, snapshots, etc..
  bin/mongorestore      - MongoDB restore a dump
  bin/mongoexport       - Export a single collection to test (JSON, CSV)
  bin/mongoimport       - Import from JSON or CSV
  bin/mongofiles        - Utility for putting and getting files from MongoDB GridFS
  bin/mongostat         - Show performance statistics

RUNNING

  To init a cluster server database:

    ./init.sh
    