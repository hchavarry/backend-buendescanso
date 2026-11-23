import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import pool from "./database.js";

dotenv.config();

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

//El select este es solo una query default para probar si se comunica con la base porque todavia no tenemos tablas
pool.query('SELECT $1::text as message', ['Se conecto bien'])
    .then((resultado) => {
        console.log(resultado.rows[0]);
    })
    .catch((error) => {
        console.error("error al conectar con postgre:", error);
    });


app.use(
  cors({
    origin: [
      "http://localhost:4200",
      "http://127.0.0.1:4200",
    ],
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  })
);

export default app;