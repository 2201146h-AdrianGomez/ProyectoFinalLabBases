-- ============================================================
-- PROYECTO FINAL - LABORATORIO DE BASES DE DATOS
-- Sistema de Gestión para Proveedor de Servicios de Internet (ISP)
-- Motor: PostgreSQL 14+
-- ============================================================

DROP SCHEMA IF EXISTS isp CASCADE;
CREATE SCHEMA isp;
SET search_path TO isp;

CREATE TABLE NODO (
    id_nodo          SERIAL       NOT NULL,
    nombre           VARCHAR(100) NOT NULL,
    capacidad_maxima INT          NOT NULL,
    ubicacion        VARCHAR(200) NOT NULL,
    CONSTRAINT pk_nodo PRIMARY KEY (id_nodo)
);

CREATE TABLE ZONA (
    id_zona INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    nombre  VARCHAR(100) NOT NULL,
    id_nodo INT          NOT NULL,
    CONSTRAINT pk_zona      PRIMARY KEY (id_zona),
    CONSTRAINT fk_zona_nodo FOREIGN KEY (id_nodo) REFERENCES NODO(id_nodo)
);

CREATE TABLE CLIENTE (
    id_cliente       INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    nombre           VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    telefono         VARCHAR(20),
    email            VARCHAR(150),
    RFC              VARCHAR(13),
    id_zona          INT          NOT NULL,
    CONSTRAINT pk_cliente      PRIMARY KEY (id_cliente),
    CONSTRAINT fk_cliente_zona FOREIGN KEY (id_zona) REFERENCES ZONA(id_zona)
);

CREATE TABLE PLAN (
    id_plan            INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    nombre             VARCHAR(100)  NOT NULL,
    velocidad_descarga INT           NOT NULL,
    velocidad_subida   INT           NOT NULL,
    precio_mensual     NUMERIC(10,2) NOT NULL,
    activo             BOOLEAN       NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_plan PRIMARY KEY (id_plan)
);

CREATE TABLE EQUIPO (
    id_equipo    INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    numero_serie VARCHAR(100) NOT NULL,
    modelo       VARCHAR(100) NOT NULL,
    tipo         VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_equipo       PRIMARY KEY (id_equipo),
    CONSTRAINT uq_equipo_serie UNIQUE (numero_serie)
);

CREATE TABLE CONTRATO (
    id_contrato  INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    fecha_inicio DATE        NOT NULL,
    fecha_fin    DATE,
    estado       VARCHAR(20) NOT NULL DEFAULT 'activo',
    id_cliente   INT         NOT NULL,
    id_plan      INT         NOT NULL,
    CONSTRAINT pk_contrato         PRIMARY KEY (id_contrato),
    CONSTRAINT fk_contrato_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente),
    CONSTRAINT fk_contrato_plan    FOREIGN KEY (id_plan)    REFERENCES PLAN(id_plan)
);

CREATE TABLE CONTRATO_EQUIPO (
    id_contrato_equipo INT  NOT NULL GENERATED ALWAYS AS IDENTITY,
    fecha_asignacion   DATE NOT NULL,
    fecha_devolucion   DATE,
    id_contrato        INT  NOT NULL,
    id_equipo          INT  NOT NULL,
    CONSTRAINT pk_contrato_equipo PRIMARY KEY (id_contrato_equipo),
    CONSTRAINT fk_ce_contrato     FOREIGN KEY (id_contrato) REFERENCES CONTRATO(id_contrato),
    CONSTRAINT fk_ce_equipo       FOREIGN KEY (id_equipo)   REFERENCES EQUIPO(id_equipo)
);

CREATE TABLE PAGO (
    id_pago           INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    monto             NUMERIC(10,2) NOT NULL,
    fecha_pago        DATE,
    fecha_vencimiento DATE          NOT NULL,
    estado            VARCHAR(20)   NOT NULL DEFAULT 'pendiente',
    id_contrato       INT           NOT NULL,
    CONSTRAINT pk_pago          PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_contrato FOREIGN KEY (id_contrato) REFERENCES CONTRATO(id_contrato)
);

CREATE TABLE FACTURA (
    id_factura  INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    folio       VARCHAR(50)   NOT NULL,
    fecha       DATE          NOT NULL,
    total       NUMERIC(10,2) NOT NULL,
    id_contrato INT           NOT NULL,
    CONSTRAINT pk_factura          PRIMARY KEY (id_factura),
    CONSTRAINT uq_factura_folio    UNIQUE (folio),
    CONSTRAINT fk_factura_contrato FOREIGN KEY (id_contrato) REFERENCES CONTRATO(id_contrato)
);

CREATE TABLE PAGO_FACTURA (
    id_pago    INT NOT NULL,
    id_factura INT NOT NULL,
    CONSTRAINT pk_pago_factura PRIMARY KEY (id_pago, id_factura),
    CONSTRAINT fk_pf_pago      FOREIGN KEY (id_pago)    REFERENCES PAGO(id_pago),
    CONSTRAINT fk_pf_factura   FOREIGN KEY (id_factura) REFERENCES FACTURA(id_factura)
);

CREATE TABLE TECNICO (
    id_tecnico       INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
    nombre           VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    telefono         VARCHAR(20),
    email            VARCHAR(150),
    CONSTRAINT pk_tecnico PRIMARY KEY (id_tecnico)
);

CREATE TABLE ORDEN_SERVICIO (
    id_orden    INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    tipo        VARCHAR(50) NOT NULL,
    fecha       DATE        NOT NULL,
    estado      VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    descripcion TEXT,
    id_contrato INT         NOT NULL,
    id_tecnico  INT         NOT NULL,
    CONSTRAINT pk_orden          PRIMARY KEY (id_orden),
    CONSTRAINT fk_orden_contrato FOREIGN KEY (id_contrato) REFERENCES CONTRATO(id_contrato),
    CONSTRAINT fk_orden_tecnico  FOREIGN KEY (id_tecnico)  REFERENCES TECNICO(id_tecnico)
);

CREATE TABLE CAMBIO_EQUIPO (
    id_cambio_equipo   INT  NOT NULL GENERATED ALWAYS AS IDENTITY,
    fecha              DATE NOT NULL,
    id_orden           INT  NOT NULL,
    id_equipo_anterior INT  NOT NULL,
    id_equipo_nuevo    INT  NOT NULL,
    CONSTRAINT pk_cambio_equipo    PRIMARY KEY (id_cambio_equipo),
    CONSTRAINT fk_ce2_orden        FOREIGN KEY (id_orden)           REFERENCES ORDEN_SERVICIO(id_orden),
    CONSTRAINT fk_ce2_equipo_ant   FOREIGN KEY (id_equipo_anterior) REFERENCES EQUIPO(id_equipo),
    CONSTRAINT fk_ce2_equipo_nuevo FOREIGN KEY (id_equipo_nuevo)    REFERENCES EQUIPO(id_equipo)
);

CREATE TABLE CAMBIO_PLAN (
    id_cambio_plan   INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
    fecha_cambio     DATE          NOT NULL,
    dias_restantes   INT           NOT NULL,
    monto_ajuste     NUMERIC(10,2) NOT NULL,
    tipo_ajuste      VARCHAR(10)   NOT NULL,
    abono_aplicado   BOOLEAN       NOT NULL DEFAULT FALSE,
    id_contrato      INT           NOT NULL,
    id_plan_anterior INT           NOT NULL,
    id_plan_nuevo    INT           NOT NULL,
    CONSTRAINT pk_cambio_plan      PRIMARY KEY (id_cambio_plan),
    CONSTRAINT fk_cp_contrato      FOREIGN KEY (id_contrato)      REFERENCES CONTRATO(id_contrato),
    CONSTRAINT fk_cp_plan_anterior FOREIGN KEY (id_plan_anterior) REFERENCES PLAN(id_plan),
    CONSTRAINT fk_cp_plan_nuevo    FOREIGN KEY (id_plan_nuevo)    REFERENCES PLAN(id_plan)
);