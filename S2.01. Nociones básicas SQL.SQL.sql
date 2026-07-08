
#NIVEL 1
/*Ejercicio 1
A partir de los documentos adjuntos (estructura_datos y datos_introducir), importa las dos tablas. 
Muestra las principales características del esquema creado y explica las diferentes tablas y variables que existen
Asegúrate de incluir un diagrama que ilustre la relación entre las distintas tablas y variables.*/

USE transactions;
/* Ejercicio 2
Utilizando JOIN realizarás las siguientes consultas */

#Listado de los países que están generando ventas.
SELECT c.country, COUNT(t.amount) AS ventas_generadas
FROM company c
JOIN transaction t
ON c.id = t.company_id
GROUP BY c.country
ORDER BY ventas_generadas;


#Desde cuántos países se generan las ventas.
SELECT COUNT(DISTINCT c.country) AS cant_paises
FROM company c
JOIN transaction t
ON c.id = t.company_id; 


#Identifica a la compañía con la mayor media de ventas
SELECT c.id, c.company_name, ROUND(AVG(t.amount)) AS med_ventas
FROM company c
JOIN transaction t
ON c.id = t.company_id
GROUP BY c.id, c.company_name
ORDER BY med_ventas DESC
LIMIT 1;

/*Ejercicio 3
Utilizando sólo subconsultas (sin utilizar JOIN): */
#Muestra todas las transacciones realizadas por empresas de Alemania.
SELECT *, 
(SELECT DISTINCT country
FROM company
WHERE country LIKE "Germany") AS pais
FROM transaction t
WHERE EXISTS
(SELECT id 
FROM company c
WHERE t.company_id = c.id
AND country = 'Germany')
ORDER BY amount DESC; 


#Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
SELECT company_name
FROM company c
WHERE EXISTS (
SELECT company_id 
FROM transaction t
WHERE c.id = t.company_id
AND amount > (SELECT AVG(amount) FROM transaction)
); 

#Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.
SELECT company_name
FROM company c
WHERE NOT EXISTS (
SELECT DISTINCT company_id 
FROM transaction t
WHERE c.id = t.company_id
AND company_id IS NOT NULL
);  


/* Ejercicio 4
Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. 
La nueva tabla debe ser capaz de identificar de forma única cada tarjeta */
CREATE TABLE credit_card (
id VARCHAR(100) PRIMARY KEY,
iban VARCHAR(250) NOT NULL,
pan VARCHAR(250) NOT NULL,
pin VARCHAR(250) NOT NULL,
cvv VARCHAR(250) NOT NULL,
expiring_date VARCHAR(250) NOT NULL
); 

/*y establecer una relación adecuada con las otras dos tablas ("transaction" y "company").  */
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);


/*Ejercicio 5
El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938. 
La información que debe mostrarse para este registro es: TR323456312213576817699999. 
Recuerda mostrar que el cambio se realizó.*/ 

# Verificamos que exista el ID CcU-2938 y que el registro es incorrecto en la tabla credit_card
SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';  

#Realización del cambio solicitado
UPDATE credit_card
SET iban = "TR323456312213576817699999"
WHERE id = "CcU-2938";

#Realizamos una verificación de que el cambio se haya realizado correctamente
SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';  


/*Ejercicio 6
En la tabla "transaction" ingresa una nueva transacción con la siguiente información:*/
/*Id, 108B1D1D-5B23-A76C-55EF-C568E49A99DD 
credit_card_id, CcU-9999 
company_id, b-9999 
user_id, 9999  
lat, 829.999  
longitude, -117.999 
amount, 111.11  
declined, 0 */ 

#Debido a que las tablas están relacionadas, antes de ingresar la información a la tabla transaction, 
#primero debo ingresar datos a las tablas credit_card y comapany.
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
VALUES ("CcU-9999", "XX0000000000000000000000000000", "1111222233334444", "1234", "999", "12/30/30");

INSERT INTO company  (id, company_name, phone, email, country, website)
VALUES ("b-9999", "Jabones lux", "600000000", "jaboneslux@jaboneslux.com", "Spain", "www.jaboneslux.com");


# Ahora procedemos a ingresar los valores indicados para la tabla transaction y verificamos que se hayan introducido correctamente
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", 9999, 829.999, -117.999, 111.11, 0 );

SELECT id, credit_card_id, company_id, user_id, lat, longitude, amount, declined
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD'; 


/*Ejercicio 7
Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.*/
ALTER TABLE credit_card DROP COLUMN pan; 



/*Ejercicio 8
Descarga los archivos CSV que encontrarás en el apartado de recursos :
american_users.csv
european_users.csv
companies.csv
credit_cards.csv
transactions.csv */

/*Estudia y diseña una base de datos con un esquema de estrella que contenga, al menos 4 tablas*/

CREATE SCHEMA data;
USE data;

CREATE TABLE IF NOT EXISTS users(
id VARCHAR(15) PRIMARY KEY,
name VARCHAR(255),
surname VARCHAR(255),
phone VARCHAR(100),
email VARCHAR(100),
birth_date VARCHAR(100),
country VARCHAR(255),
city VARCHAR(255),
postal_code VARCHAR(100),
address VARCHAR(100),
signup_date VARCHAR(100),
user_segment VARCHAR(255),
income_band VARCHAR(255),
continent VARCHAR(255)
);   

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS (id,name,surname,phone,email,birth_date,country,city,postal_code,address,signup_date,user_segment,income_band)
SET continent = 'american';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS (id,name,surname,phone,email,birth_date,country,city,postal_code,address,signup_date,user_segment,income_band)
SET continent = 'european'; 

CREATE TABLE IF NOT EXISTS companies(
company_id VARCHAR(15) PRIMARY KEY,
company_name VARCHAR(255),
phone VARCHAR(100),
email VARCHAR(100),
country VARCHAR(255),
website VARCHAR(255),
merchant_category VARCHAR(255),
merchant_price_position VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

CREATE TABLE IF NOT EXISTS credit_cards(
id VARCHAR(15) PRIMARY KEY,
user_id VARCHAR(15),
iban VARCHAR(50),
pan VARCHAR(30),
pin VARCHAR(4),
cvv VARCHAR(4),
track1 VARCHAR(100),
track2 VARCHAR(100),
expiring_date VARCHAR(20),
card_type VARCHAR(255),
card_renewal_flag VARCHAR(255)
); 

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

CREATE TABLE IF NOT EXISTS transactions(
id VARCHAR(500) PRIMARY KEY,
card_id VARCHAR(500),
business_id VARCHAR(15),
timestamp VARCHAR(500),
amount DECIMAL(10, 2),
declined BOOLEAN,
product_ids VARCHAR(255),
user_id VARCHAR(15),
lat FLOAT,
longitude FLOAT,
discount_amount FLOAT,
tax_amount DECIMAL(10, 2),
shipping_amount DECIMAL(10, 2),
channel VARCHAR(255),
campaign_id VARCHAR(15),
device_type VARCHAR(255),
is_international FLOAT,
decline_reason VARCHAR(255),
distance_km DECIMAL(10, 2),
FOREIGN KEY (card_id) REFERENCES credit_cards(id),
FOREIGN KEY (business_id) REFERENCES companies(company_id),
FOREIGN KEY (user_id) REFERENCES users(id)
); 

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


/*Ejercicio 9
Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.*/
SELECT id, name, surname
FROM users u
INNER JOIN (SELECT user_id, declined
FROM transactions 
GROUP BY user_id, declined
HAVING COUNT(*) > 80) AS t
ON u.id = t.user_id
WHERE t.declined = 0; 

/*Ejercicio 10
Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.*/
SELECT cc.iban, AVG(t.amount) AS media_amount, (SELECT company_name
FROM companies
WHERE company_name = 'Donec Ltd'
) AS companies
FROM transactions t
JOIN credit_cards cc ON t.card_id = cc.id
WHERE t.business_id IN 
(SELECT company_id
FROM companies
WHERE company_name = 'Donec Ltd'
)
GROUP BY cc.iban
ORDER BY media_amount;



#Nivel 2
USE data;

/*Ejercicio 1
Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. 
Muestra la fecha de cada transacción junto con el total de las ventas.*/
SELECT DATE(timestamp) AS fecha, SUM(amount) AS total_ventas
FROM transactions
GROUP BY DATE(timestamp)
ORDER BY total_ventas DESC
LIMIT 5; 

/* Ejercicio 2 
Presenta el nombre, teléfono, país, fecha y amount, 
de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros
 y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. 
 Ordena los resultados de mayor a menor cantidad.*/
SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS fecha, t.amount
FROM companies c
INNER JOIN transactions t
ON c.company_id = t.business_id
WHERE t.amount BETWEEN 350 AND 400
AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY t.amount DESC;  
 
 
 /*Ejercicio 3
Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, 
por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, 
pero el departamento de recursos humanos es exigente y quiere un listado de las empresas 
en las que especifiques si tienen igual o más de 400 transacciones o menos.*/
SELECT c.company_name, COUNT(*) AS cant_transacciones,
CASE WHEN COUNT(*) >= 400 THEN 'Igual o más de 400'
ELSE 'Menos de 400'
END AS categoria_transacciones
FROM companies c
JOIN transactions t
ON c.company_id = t.business_id
GROUP BY c.company_id, c.company_name
ORDER BY cant_transacciones;


/*Ejercicio 4
Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.*/

#Verificamos que exista el ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD en la tabla transaccions
SELECT id
FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'; 

#Se elimina el registro y realizamos una verificación de que el cambio se haya realizado correctamente
DELETE FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'; 

SELECT id
FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'; 


/*Ejercicio 5
La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. 
Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información: 
Nombre de la compañía. Teléfono de contacto. País de residencia. Media de compra realizado por cada compañía.*/
 CREATE VIEW VistaMarketing AS 
 SELECT c.company_name, c.phone, c.country, AVG(t.amount) AS med_compras
 FROM companies c
 JOIN transactions t
 ON c.company_id = t.business_id
 GROUP BY  c.company_id, c.company_name, c.phone, c.country
 ORDER BY med_compras DESC; 


/*Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra. */
 SELECT * FROM VistaMarketing; 
 
 
 #Nivel 3
 USE data;
/*Ejercicio 1
Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las tres últimas transacciones han sido declinadas 
entonces es inactivo, si al menos una no es rechazada entonces es activo. Partiendo de esta tabla responde:*/
CREATE TABLE estado_tarjetas AS
SELECT card_id,
CASE WHEN SUM(CASE WHEN declined = 0 THEN 1 ELSE 0 END) >= 1
THEN 'Activa' ELSE 'Inactiva'
END AS estado
FROM(
SELECT card_id, declined, timestamp,
ROW_NUMBER() OVER ( PARTITION BY card_id
ORDER BY timestamp DESC
)  AS rn
FROM transactions
) ultimas
WHERE ultimas.rn <= 3
GROUP BY  card_id; 

ALTER TABLE estado_tarjetas
ADD CONSTRAINT fk_cards_tarjetas_credit
FOREIGN KEY (card_id) REFERENCES credit_cards(id);


#👉 ¿Cuántas tarjetas están activas?
SELECT COUNT(*) AS cant_tarjetas, estado
FROM estado_tarjetas
WHERE estado = 'Activa'
group by estado; 


/*Ejercicio 2
Crea una tabla con la que podamos unir los datos del archivo de products.csv con la base de datos creada 
(ya que hasta ahora no podíamos hacerlo), teniendo en cuenta que desde transaction tienes product_ids. */

/* creacion tabla products*/
CREATE TABLE IF NOT EXISTS products(
id VARCHAR(15) PRIMARY KEY,
product_name VARCHAR(255),
price VARCHAR(100),
colour VARCHAR(100),
weight VARCHAR(255),
warehouse_id VARCHAR(255),
category VARCHAR(255),
brand VARCHAR(255),
cost VARCHAR(255),
launch_date VARCHAR(255)
); 

/* Carga datos tabla products*/
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

CREATE TABLE transct_products (
transaction_id VARCHAR(500) NOT NULL,
product_id VARCHAR(15) NOT NULL,
PRIMARY KEY (transaction_id, product_id),
CONSTRAINT fk_tp_transaction
FOREIGN KEY (transaction_id) REFERENCES transactions(id),
CONSTRAINT fk_tp_product
FOREIGN KEY (product_id) REFERENCES products(id)
);  

INSERT INTO transct_products (transaction_id, product_id)
SELECT t.id AS transaction_id, TRIM(jt.product_id) AS product_id
FROM transactions t
JOIN JSON_TABLE(
CONCAT('["', REPLACE(t.product_ids, ',', '","'), '"]'),
'$[*]' COLUMNS ( product_id VARCHAR(15) PATH '$'
)
) AS jt
JOIN products p
ON TRIM(jt.product_id) = p.id; 


#Genera la siguiente consulta:
#👉 Necesitamos conocer el número de veces que se ha vendido cada producto.
SELECT p.id AS product_id, p.product_name, COUNT(tp.transaction_id) AS veces_vendido
FROM products p
JOIN transct_products tp
ON p.id = tp.product_id
GROUP BY p.id, p.product_name
ORDER BY veces_vendido DESC;

