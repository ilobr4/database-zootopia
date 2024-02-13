const mysql = require('mysql');
const express = require('express');
const http = require('http');
const app = express();
const bodyParser = require('body-parser');
const methodOverride = require ('method-override');
app.use(methodOverride('_method'));
var urlencodedParser = bodyParser.urlencoded({extended: false});

// Create a MySQL connection
var con = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'passwort',
  database: 'zootopia',
  timezone: 'utc',
  multipleStatements: true
});

// Connect to MySQL
con.connect(function(err) {
  if (err) throw err;
  console.log("Connected!");
});

//error handeln
app.use(function(err, req, res, next) {
  // Handle the error here
  res.status(500).send('Internal Server Error');
});



// set the view engine to ejs
app.set('view engine', 'ejs');

app.get('/', function(req, res) {

    const sql = 'SELECT * FROM zootopia.gehege_tiere';

    con.query(sql, (err, result) => {
        if (err) throw err;

    var tagline = "Hier findest du eine Übersicht von allen Tieren und Gehegen:";

    res.render('index', { tagline: tagline, tiere: result });
  });
});

app.get('/patenschaft', function(req, res) {

    const sql = 'SELECT * FROM zootopia.tiere_ohne_paten';

    con.query(sql, (err, result) => {
      if (err) throw err;

      var tagline = "Hier findest du eine Übersicht von allen Tieren, die noch keinen Paten haben:";

    res.render('patenschaft', { tagline: tagline, tiere: result });
  });
});

app.post('/addPate', urlencodedParser, function(req, res) {

  //Prozedur!!
    var sql = "Call neuerPate('" + req.body.vorname + "', '" + req.body.nachname + "', '" + req.body.email + "', " + req.body.tier_id + ", '" + req.body.betrag.replace(",", ".") + "');";

    con.query(sql, (err, result) => {
        console.log(sql);
        if (err) throw err;
        res.send("Patenschaft wurde hinzugefügt.");
    });
});

app.get('/tiere', function(req, res) {

  const sql = 'SELECT * FROM zootopia.tiere';

  con.query(sql, (err, result) => {
    if (err) throw err;

    var tagline = "Alle Tiere:";

  res.render('tiere', { tagline: tagline, tiere: result });
});
});

app.post('/addTier', urlencodedParser, function(req, res) {


  var sql = "INSERT INTO zootopia.tiere (tier_name, geburtsdatum, geschlecht, größe, gewicht, arten_id, kategorie_id, gehege_nr) VALUES ('" + req.body.name + "', '" + req.body.geburtsdatum + "', '" + req.body.geschlechtauswahl + "' , '" + req.body.größe.replace(",", ".") + "', '" + req.body.gewicht.replace(",", ".") + "', " + req.body.artenID +  ", " + req.body.kategorieID + ", " + req.body.gehegeNr +");";

  con.query(sql, (err, result) => {
      console.log(sql);
      if (err) throw err;
      res.send("Tier wurde hinzugefügt.");
  });
});

app.post('/updateTier', urlencodedParser, function(req, res) {


  var sql = "UPDATE zootopia.tiere SET tier_name = '" + req.body.name + "', geburtsdatum = '" + req.body.geburtsdatum + "', geschlecht = '" + req.body.geschlechtauswahl + "', größe = '" + req.body.größe.replace(",", ".") + "', gewicht = '" + req.body.gewicht.replace(",", ".") + "', arten_id = " + req.body.artenID + ", kategorie_id = " + req.body.kategorieID + ", gehege_nr = "  + req.body.gehegeNr + " WHERE tiere_id = " + req.body.tierID + ";"; 

  con.query(sql, (err, result) => {
      console.log(sql);
      if (err) throw err;
      res.send("Tierdaten wurden geändert.");
  });
});

app.post('/deleteTier', urlencodedParser, function(req, res) {

  var sql = "DELETE FROM zootopia.tiere WHERE tiere_id = " + req.body.tierID + ";";

  con.query(sql, (err, result) => {
      console.log(sql);
      if (err) throw err;
      res.send("Tier wurde gelöscht.");
  });
});

app.get('/fetchTierData', function(req, res) {
  const tierID = req.query.id;

  const sql = 'SELECT * FROM zootopia.tiere WHERE tiere_id = ?';

  con.query(sql, [tierID], (err, result) => {
    if (err) throw err;

    if (result.length > 0) {
      const tierData = result[0];
       
      res.json(tierData);
    } else {
      res.json(null); // Return null if no data found for the provided ID
    }
  });
});

// Listen on port 8081
var server = app.listen('8081', function() {
  var host = server.address().address;
  var port = server.address().port;
  console.log("Server is successfully running on port 8081");
});