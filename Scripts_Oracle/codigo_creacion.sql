-- ============================================================
-- PROYECTO FINAL - LABORATORIO DE BASES DE DATOS
-- Sistema de Gestión para Proveedor de Servicios de Internet (ISP)
-- Motor: Oracle Database 12c+
-- ============================================================

BEGIN
    FOR t IN (
        SELECT table_name FROM user_tables
        WHERE table_name IN (
            'CAMBIO_PLAN','CAMBIO_EQUIPO','ORDEN_SERVICIO','TECNICO',
            'PAGO_FACTURA','FACTURA','PAGO','CONTRATO_EQUIPO',
            'CONTRATO','EQUIPO','PLAN','CLIENTE','ZONA','NODO'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/

BEGIN
    FOR s IN (
        SELECT sequence_name FROM user_sequences
        WHERE sequence_name IN (
            'SEQ_NODO','SEQ_ZONA','SEQ_CLIENTE','SEQ_PLAN','SEQ_EQUIPO',
            'SEQ_CONTRATO','SEQ_CONTRATO_EQUIPO','SEQ_PAGO','SEQ_FACTURA',
            'SEQ_TECNICO','SEQ_ORDEN','SEQ_CAMBIO_EQUIPO','SEQ_CAMBIO_PLAN'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

-- Secuencias
CREATE SEQUENCE SEQ_NODO             START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_ZONA             START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CLIENTE          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PLAN             START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_EQUIPO           START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CONTRATO         START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CONTRATO_EQUIPO  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PAGO             START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_FACTURA          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_TECNICO          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_ORDEN            START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CAMBIO_EQUIPO    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CAMBIO_PLAN      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE NODO (
    id_nodo          NUMBER        NOT NULL,
    nombre           VARCHAR2(100) NOT NULL,
    capacidad_maxima NUMBER(5)     NOT NULL,
    ubicacion        VARCHAR2(200) NOT NULL,
    CONSTRAINT pk_nodo PRIMARY KEY (id_nodo)
);
CREATE OR REPLACE TRIGGER trg_nodo_bi BEFORE INSERT ON NODO FOR EACH ROW
BEGIN IF :NEW.id_nodo IS NULL THEN SELECT SEQ_NODO.NEXTVAL INTO :NEW.id_nodo FROM DUAL; END IF; END;
/

CREATE TABLE ZONA (
    id_zona  NUMBER        NOT NULL,
    nombre   VARCHAR2(100) NOT NULL,
    id_nodo  NUMBER        NOT NULL,
    CONSTRAINT pk_zona      PRIMARY KEY (id_zona),
    CONSTRAINT fk_zona_nodo FOREIGN KEY (id_nodo) REFERENCES NODO(id_nodo)
);
CREATE OR REPLACE TRIGGER trg_zona_bi BEFORE INSERT ON ZONA FOR EACH ROW
BEGIN IF :NEW.id_zona IS NULL THEN SELECT SEQ_ZONA.NEXTVAL INTO :NEW.id_zona FROM DUAL; END IF; END;
/

CREATE TABLE CLIENTE (
    id_cliente       NUMBER        NOT NULL,
    nombre           VARCHAR2(100) NOT NULL,
    apellido_paterno VARCHAR2(100) NOT NULL,
    apellido_materno VARCHAR2(100),
    telefono         VARCHAR2(20),
    email            VARCHAR2(150),
    RFC              VARCHAR2(13),
    id_zona          NUMBER        NOT NULL,
    CONSTRAINT pk_cliente      PRIMARY KEY (id_cliente),
    CONSTRAINT fk_cliente_zona FOREIGN KEY (id_zona) REFERENCES ZONA(id_zona)
);
CREATE OR REPLACE TRIGGER trg_cliente_bi BEFORE INSERT ON CLIENTE FOR EACH ROW
BEGIN IF :NEW.id_cliente IS NULL THEN SELECT SEQ_CLIENTE.NEXTVAL INTO :NEW.id_cliente FROM DUAL; END IF; END;
/

CREATE TABLE PLAN (
    id_plan            NUMBER        NOT NULL,
    nombre             VARCHAR2(100) NOT NULL,
    velocidad_descarga NUMBER(5)     NOT NULL,
    velocidad_subida   NUMBER(5)     NOT NULL,
    precio_mensual     NUMBER(10,2)  NOT NULL,
    activo             NUMBER(1)     DEFAULT 1 NOT NULL,
    CONSTRAINT pk_plan        PRIMARY KEY (id_plan),
    CONSTRAINT ck_plan_activo CHECK (activo IN (0,1))
);
CREATE OR REPLACE TRIGGER trg_plan_bi BEFORE INSERT ON PLAN FOR EACH ROW
BEGIN IF :NEW.id_plan IS NULL THEN SELECT SEQ_PLAN.NEXTVAL INTO :NEW.id_plan FROM DUAL; END IF; END;
/

CREATE TABLE EQUIPO (
    id_equipo    NUMBER        NOT NULL,
    numero_serie VARCHAR2(100) NOT NULL,
    modelo       VARCHAR2(100) NOT NULL,
    tipo         VARCHAR2(50)  NOT NULL,
    CONSTRAINT pk_equipo       PRIMARY KEY (id_equipo),
    CONSTRAINT uq_equipo_serie UNIQUE (numero_serie)
);
CREATE OR REPLACE TRIGGER trg_equipo_bi BEFORE INSERT ON EQUIPO FOR EACH ROW
BEGIN IF :NEW.id_equipo IS NULL THEN SELECT SEQ_EQUIPO.NEXTVAL INTO :NEW.id_equipo FROM DUAL; END IF; END;
/

CREATE TABLE CONTRATO (
    id_contrato  NUMBER        NOT NULL,
    fecha_inicio DATE          NOT NULL,
    fecha_fin    DATE,
    estado       VARCHAR2(20)  DEFAULT 'activo' NOT NULL,
    id_cliente   NUMBER        NOT NULL,
    id_plan      NUMBER        NOT NULL,
    CONSTRAINT pk_contrato         PRIMARY KEY (id_contrato),
    CONSTRAINT fk_contrato_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente),
    CONSTRAINT fk_contrato_plan    FOREIGN KEY (id_plan)    REFERENCES PLAN(id_plan),
    CONSTRAINT ck_contrato_estado  CHECK (estado IN ('activo','inactivo'))
);
CREATE OR REPLACE TRIGGER trg_contrato_bi BEFORE INSERT ON CONTRATO FOR EACH ROW
BEGIN IF :NEW.id_contrato IS NULL THEN SELECT SEQ_CONTRATO.NEXTVAL INTO :NEW.id_contrato FROM DUAL; END IF; END;
/

CREATE TABLE CONTRATO_EQUIPO (
    id_contrato_equipo NUMBER NOT NULL,
    fecha_asignacion   DATE   NOT NULL,
    fecha_devolucion   DATE,
    id_contrato        NUMBER NOT NULL,
    id_equipo          NUMBER NOT NULL,
    CONSTRAINT pk_contrato_equipo PRIMARY KEY (id_contrato_equipo),
    CONSTRAINT fk_ce_contrato     FOREIGN KEY (id_contrato) REFERENCES CONTRATO(id_contrato),
    CONSTRAINT fk_ce_equipo       FOREIGN KEY (id_equipo)   REFERENCES EQUIPO(id_equipo)
);
CREATE OR REPLACE TRIGGER trg_contrato_equipo_bi BEFORE INSERT ON CONTRATO_EQUIPO FOR EACH ROW
BEGIN IF :NEW.id_contrato_equipo IS NULL THEN SELECT SEQ_CONTRATO_EQUIPO.NEXTVAL INTO :NEW.id_contrato_equipo FROM DUAL; END IF; END;
/

CREATE TABLE PAGO (
    id_pago           NUMBER       NOT NULL,
    monto             NUMBER(10,2) NOT NULL,
    fecha_pago        DATE,
    fecha_vencimiento DATE         NOT NULL,
    estado            VARCHAR2(20) DEFAULT 'pendiente' NOT NULL,
    id_contrato       NUMBER       NOT NULL,
    CONSTRAINT pk_pago          PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_contrato FOREIGN KEY (id_contrato) REFERENCES CONTRATO(id_contrato),
    CONSTRAINT ck_pago_estado   CHECK (estado IN ('pendiente','liquidado','vencido'))
);
CREATE OR REPLACE TRIGGER trg_pago_bi BEFORE INSERT ON PAGO FOR EACH ROW
BEGIN IF :NEW.id_pago IS NULL THEN SELECT SEQ_PAGO.NEXTVAL INTO :NEW.id_pago FROM DUAL; END IF; END;
/

CREATE TABLE FACTURA (
    id_factura  NUMBER        NOT NULL,
    folio       VARCHAR2(50)  NOT NULL,
    fecha       DATE          NOT NULL,
    total       NUMBER(10,2)  NOT NULL,
    id_contrato NUMBER        NOT NULL,
    CONSTRAINT pk_factura          PRIMARY KEY (id_factura),
    CONSTRAINT uq_factura_folio    UNIQUE (folio),
    CONSTRAINT fk_factura_contrato FOREIGN KEY (id_contrato) REFERENCES CONTRATO(id_contrato)
);
CREATE OR REPLACE TRIGGER trg_factura_bi BEFORE INSERT ON FACTURA FOR EACH ROW
BEGIN IF :NEW.id_factura IS NULL THEN SELECT SEQ_FACTURA.NEXTVAL INTO :NEW.id_factura FROM DUAL; END IF; END;
/

CREATE TABLE PAGO_FACTURA (
    id_pago    NUMBER NOT NULL,
    id_factura NUMBER NOT NULL,
    CONSTRAINT pk_pago_factura PRIMARY KEY (id_pago, id_factura),
    CONSTRAINT fk_pf_pago      FOREIGN KEY (id_pago)    REFERENCES PAGO(id_pago),
    CONSTRAINT fk_pf_factura   FOREIGN KEY (id_factura) REFERENCES FACTURA(id_factura)
);

CREATE TABLE TECNICO (
    id_tecnico       NUMBER        NOT NULL,
    nombre           VARCHAR2(100) NOT NULL,
    apellido_paterno VARCHAR2(100) NOT NULL,
    apellido_materno VARCHAR2(100),
    telefono         VARCHAR2(20),
    email            VARCHAR2(150),
    CONSTRAINT pk_tecnico PRIMARY KEY (id_tecnico)
);
CREATE OR REPLACE TRIGGER trg_tecnico_bi BEFORE INSERT ON TECNICO FOR EACH ROW
BEGIN IF :NEW.id_tecnico IS NULL THEN SELECT SEQ_TECNICO.NEXTVAL INTO :NEW.id_tecnico FROM DUAL; END IF; END;
/

CREATE TABLE ORDEN_SERVICIO (
    id_orden    NUMBER        NOT NULL,
    tipo        VARCHAR2(50)  NOT NULL,
    fecha       DATE          NOT NULL,
    estado      VARCHAR2(30)  DEFAULT 'pendiente' NOT NULL,
    descripcion CLOB,
    id_contrato NUMBER        NOT NULL,
    id_tecnico  NUMBER        NOT NULL,
    CONSTRAINT pk_orden          PRIMARY KEY (id_orden),
    CONSTRAINT fk_orden_contrato FOREIGN KEY (id_contrato) REFERENCES CONTRATO(id_contrato),
    CONSTRAINT fk_orden_tecnico  FOREIGN KEY (id_tecnico)  REFERENCES TECNICO(id_tecnico),
    CONSTRAINT ck_orden_tipo     CHECK (tipo    IN ('instalacion','mantenimiento','falla','cambio_equipo')),
    CONSTRAINT ck_orden_estado   CHECK (estado  IN ('pendiente','en_proceso','completada'))
);
CREATE OR REPLACE TRIGGER trg_orden_bi BEFORE INSERT ON ORDEN_SERVICIO FOR EACH ROW
BEGIN IF :NEW.id_orden IS NULL THEN SELECT SEQ_ORDEN.NEXTVAL INTO :NEW.id_orden FROM DUAL; END IF; END;
/

CREATE TABLE CAMBIO_EQUIPO (
    id_cambio_equipo   NUMBER NOT NULL,
    fecha              DATE   NOT NULL,
    id_orden           NUMBER NOT NULL,
    id_equipo_anterior NUMBER NOT NULL,
    id_equipo_nuevo    NUMBER NOT NULL,
    CONSTRAINT pk_cambio_equipo    PRIMARY KEY (id_cambio_equipo),
    CONSTRAINT fk_ce2_orden        FOREIGN KEY (id_orden)           REFERENCES ORDEN_SERVICIO(id_orden),
    CONSTRAINT fk_ce2_equipo_ant   FOREIGN KEY (id_equipo_anterior) REFERENCES EQUIPO(id_equipo),
    CONSTRAINT fk_ce2_equipo_nuevo FOREIGN KEY (id_equipo_nuevo)    REFERENCES EQUIPO(id_equipo)
);
CREATE OR REPLACE TRIGGER trg_cambio_equipo_bi BEFORE INSERT ON CAMBIO_EQUIPO FOR EACH ROW
BEGIN IF :NEW.id_cambio_equipo IS NULL THEN SELECT SEQ_CAMBIO_EQUIPO.NEXTVAL INTO :NEW.id_cambio_equipo FROM DUAL; END IF; END;
/

CREATE TABLE CAMBIO_PLAN (
    id_cambio_plan   NUMBER        NOT NULL,
    fecha_cambio     DATE          NOT NULL,
    dias_restantes   NUMBER(3)     NOT NULL,
    monto_ajuste     NUMBER(10,2)  NOT NULL,
    tipo_ajuste      VARCHAR2(10)  NOT NULL,
    abono_aplicado   NUMBER(1)     DEFAULT 0 NOT NULL,
    id_contrato      NUMBER        NOT NULL,
    id_plan_anterior NUMBER        NOT NULL,
    id_plan_nuevo    NUMBER        NOT NULL,
    CONSTRAINT pk_cambio_plan      PRIMARY KEY (id_cambio_plan),
    CONSTRAINT fk_cp_contrato      FOREIGN KEY (id_contrato)      REFERENCES CONTRATO(id_contrato),
    CONSTRAINT fk_cp_plan_anterior FOREIGN KEY (id_plan_anterior) REFERENCES PLAN(id_plan),
    CONSTRAINT fk_cp_plan_nuevo    FOREIGN KEY (id_plan_nuevo)    REFERENCES PLAN(id_plan),
    CONSTRAINT ck_cp_tipo_ajuste   CHECK (tipo_ajuste     IN ('cargo','abono')),
    CONSTRAINT ck_cp_abono         CHECK (abono_aplicado  IN (0,1))
);
CREATE OR REPLACE TRIGGER trg_cambio_plan_bi BEFORE INSERT ON CAMBIO_PLAN FOR EACH ROW
BEGIN IF :NEW.id_cambio_plan IS NULL THEN SELECT SEQ_CAMBIO_PLAN.NEXTVAL INTO :NEW.id_cambio_plan FROM DUAL; END IF; END;
/