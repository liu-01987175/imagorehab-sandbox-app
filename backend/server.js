// backend/server.js
const express = require('express');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');

// replace with your Atlas URI
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
  app.use(cors());
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

  const port = process.env.PORT || 3000;
  app.listen(port, () => console.log(`API listening on http://localhost:${port}`));
}

start().catch(err => {
  console.error(err);
  process.exit(1);
});
