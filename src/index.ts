import express from 'express';
import { APP_PORT, APP_TMP_PATH } from './constants';
import { launch } from './launcher';

const app = express();
app.use(express.json());
app.use(express.static(APP_TMP_PATH))

app.post('/', async (req, res) => {
  const response = await launch(req.body)
  res.send(response)
});


app.listen(APP_PORT, () => {
  return console.log(`Express is listening at http://localhost:${APP_PORT}`);
});