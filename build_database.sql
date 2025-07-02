-- Drop existing tables
DROP TABLE IF EXISTS properties, elements, types;

-- Create table: types
CREATE TABLE types (
  type_id SERIAL PRIMARY KEY,
  type VARCHAR NOT NULL
);

-- Insert element types
INSERT INTO types(type) VALUES 
('metal'), 
('nonmetal'), 
('metalloid');

-- Create table: elements
CREATE TABLE elements (
  atomic_number INTEGER PRIMARY KEY,
  symbol VARCHAR UNIQUE NOT NULL,
  name VARCHAR UNIQUE NOT NULL
);

-- Create table: properties
CREATE TABLE properties (
  atomic_number INTEGER PRIMARY KEY,
  atomic_mass DECIMAL NOT NULL,
  melting_point_celsius REAL NOT NULL,
  boiling_point_celsius REAL NOT NULL,
  type_id INT_

psql --username=freecodecamp --dbname=periodic_table -f build_database.sql

cat > element.sh << 'EOF'
#!/bin/bash

# Conexión a la base de datos
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Verifica si hay argumento
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Detecta si es número (atomic_number) o texto (symbol/name)
if [[ $1 =~ ^[0-9]+$ ]]; then
  QUERY_RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  JOIN types t ON p.type_id = t.type_id
  WHERE e.atomic_number = $1")
else
  QUERY_RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  JOIN types t ON p.type_id = t.type_id
  WHERE e.symbol = INITCAP('$1') OR e.name = INITCAP('$1')")
fi

# Si no encontró resultados
if [[ -z $QUERY_RESULT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Mostrar resultado formateado
echo "$QUERY_RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL
do
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
done
