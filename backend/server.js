// backend/server.js

const express = require('express');
const cors = require('cors');

/*
  todo:
  1. implement check off(delete) a task
  2. implement edit (update) a task
*/

const { MongoClient, ObjectId } = require('mongodb');

// Mongo DB Atlas URI
const uri = 'mongodb+srv://app_user:%23Sl217308162@task-tracker.256j6gh.mongodb.net/taskdb?retryWrites=true&w=majority';
const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

let tasksColl;

async function start() {
  await client.connect();
  const db = client.db('taskdb');
  tasksColl = db.collection('tasks');

  const app = express();
  app.use(cors({
    origin: '*',
    methods: ['GET','POST','PUT','DELETE','OPTIONS']
  }));
  app.use(express.json());

  // fetch all tasks
  app.get('/tasks', async (req, res) => {
    const all = await tasksColl.find().toArray();
    res.json(all);
  });

  // add a task
  app.post('/tasks', async (req, res) => {
    const { name, description, date } = req.body;
    const result = await tasksColl.insertOne({ name, description, date });
    res.json({ _id: result.insertedId });
  });

  // DELETE a task by its ObjectId (check off)
  app.delete('/tasks/:id', async (req, res) => {
    try {
      const id = req.params.id;
      const result = await tasksColl.deleteOne({ _id: new ObjectId(id) });
      if (result.deletedCount === 1) {
        res.json({ success: true });
      } else {
        res.status(404).json({ success: false, message: 'Not found' });
      }
    } catch (err) {
      res.status(400).json({ success: false, message: err.message });
    }
  });

  // PUT /tasks/:id to update (edit) a task
  app.put('/tasks/:id', async (req, res) => {
    try {
      const id = req.params.id;
      const { name, description, date } = req.body;
      const result = await tasksColl.updateOne(
        { _id: new ObjectId(id) },
        { $set: { name, description, date } }
      );
      if (result.matchedCount === 1) {
        res.json({ success: true });
      } else {
        res.status(404).json({ success: false, message: 'Not found' });
      }
    } catch (err) {
      res.status(400).json({ success: false, message: err.message });
    }
  });

  const port = process.env.PORT || 3000;
  app.listen(port, () => console.log(`API listening on http://localhost:${port}`));
}

start().catch(err => {
  console.error(err);
  process.exit(1);
});
