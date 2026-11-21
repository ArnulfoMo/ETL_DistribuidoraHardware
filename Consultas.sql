
-- 1. DIM_PuestoEmp
SELECT DISTINCT
    E.job_title AS NOMBRE
FROM DB_DH.dbo.employees E
WHERE E.job_title IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM DW_DistribucionHardware.dbo.DIM_PuestoEmp D
    WHERE D.NOMBRE = E.job_title
);


-- 2. DIM_DominioCorreoEmp
SELECT DISTINCT
    RIGHT(E.email, LEN(E.email) - CHARINDEX('@', E.email)) AS NOMBRE
FROM DB_DH.dbo.employees E
WHERE E.email LIKE '%@%'
AND NOT EXISTS (
    SELECT 1
    FROM DW_DistribucionHardware.dbo.DIM_DominioCorreoEmp D
    WHERE D.NOMBRE = RIGHT(
        E.email,
        LEN(E.email) - CHARINDEX('@', E.email)
    )
);


-- 3. DIM_CATEGORIA
SELECT
    C.category_id AS ID_CATEGORIA,
    CAST(C.category_id AS NVARCHAR(50)) AS CODIGO,
    C.category_name AS NOMBRE
FROM DB_DH.dbo.product_categories C
WHERE NOT EXISTS (
    SELECT 1
    FROM DW_DistribucionHardware.dbo.DIM_CATEGORIA D
    WHERE D.ID_CATEGORIA = C.category_id
);


-- 4. DIM_TIEMPO
SELECT DISTINCT
    YEAR(O.order_date) * 10000 +
    MONTH(O.order_date) * 100 +
    DAY(O.order_date) AS ID_TIEMPO,

    DATEPART(WEEK, O.order_date) AS SEMANA,
    DATEPART(QUARTER, O.order_date) AS TRIMESTRE,
    ((MONTH(O.order_date) - 1) / 4) + 1 AS CUATRIMESTRE,
    DATENAME(WEEKDAY, O.order_date) AS DIA_SEMANA,
    DATENAME(MONTH, O.order_date) AS NOMBRE_MES

FROM DB_DH.dbo.orders O
WHERE O.order_date IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM DW_DistribucionHardware.dbo.DIM_TIEMPO D
    WHERE D.ID_TIEMPO =
        YEAR(O.order_date) * 10000 +
        MONTH(O.order_date) * 100 +
        DAY(O.order_date)
);

-- 5. DIM_EMPLEADO
SELECT
    E.employee_id AS ID_EMPLEADO,
    E.first_name + ' ' + E.last_name AS NOMBRE_COMPLETO,
    P.ID_PUESTO,
    D.ID_DOMINIO
FROM DB_DH.dbo.employees E

INNER JOIN DW_DistribucionHardware.dbo.DIM_PuestoEmp P
    ON P.NOMBRE = E.job_title

INNER JOIN DW_DistribucionHardware.dbo.DIM_DominioCorreoEmp D
    ON D.NOMBRE = SUBSTRING(
        E.email,
        CHARINDEX('@', E.email) + 1,
        LEN(E.email)
    )

WHERE NOT EXISTS (
    SELECT 1
    FROM DW_DistribucionHardware.dbo.DIM_EMPLEADO DE
    WHERE DE.ID_EMPLEADO = E.employee_id
);


-- 6. DIM_PRODUCTO
SELECT
    P.product_id AS ID_PRODUCTO,
    P.category_id AS ID_CATEGORIA,
    P.product_name AS NOMBRE,
    P.description AS DESCRIPCION
FROM DB_DH.dbo.products P
WHERE NOT EXISTS (
    SELECT 1
    FROM DW_DistribucionHardware.dbo.DIM_PRODUCTO D
    WHERE D.ID_PRODUCTO = P.product_id
);


-- 7. DIM_CLIENTES
SELECT
    C.customer_id AS ID_CLIENTE,
    C.name AS NOMBRE_COMPLETO,
    C.address AS DIRECCION
FROM DB_DH.dbo.customers C
WHERE NOT EXISTS (
    SELECT 1
    FROM DW_DistribucionHardware.dbo.DIM_CLIENTES D
    WHERE D.ID_CLIENTE = C.customer_id
);


-- 8. HECHO_VENTAS
SELECT
    O.order_id AS ID_VENTA,

    YEAR(O.order_date) * 10000 +
    MONTH(O.order_date) * 100 +
    DAY(O.order_date) AS ID_TIEMPO,

    O.salesman_id AS ID_EMPLEADO,
    OI.product_id AS ID_PRODUCTO,
    O.customer_id AS ID_CLIENTE,
    OI.quantity AS CANTIDAD_VENTA

FROM DB_DH.dbo.orders O

INNER JOIN DB_DH.dbo.order_items OI
    ON OI.order_id = O.order_id

WHERE O.salesman_id IS NOT NULL
AND O.order_date IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM DW_DistribucionHardware.dbo.HECHO_VENTAS D
    WHERE D.ID_VENTA = O.order_id
      AND D.ID_PRODUCTO = OI.product_id
);