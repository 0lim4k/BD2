
-- Crear base de datos
CREATE DATABASE payroll_mgmt CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE payroll_mgmt;

-- Tabla de áreas
CREATE TABLE org_areas (
    vn_area_id INT AUTO_INCREMENT PRIMARY KEY,
    vc_area_name VARCHAR(100) NOT NULL,
    vc_area_desc TEXT,
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Cargos o roles laborales
CREATE TABLE job_roles (
    vn_role_id INT AUTO_INCREMENT PRIMARY KEY,
    vc_role_name VARCHAR(100) NOT NULL,
    vn_area_id INT,
    vn_base_salary DECIMAL(12,2) NOT NULL,
    vc_description TEXT,
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vn_area_id) REFERENCES org_areas(vn_area_id)
);

-- Tipos de contrato
CREATE TABLE contract_modes (
    vn_mode_id INT AUTO_INCREMENT PRIMARY KEY,
    vc_mode_name VARCHAR(100) NOT NULL,
    vc_description TEXT,
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Información personal del trabajador (nueva división)
CREATE TABLE personal_info (
    vn_person_id INT AUTO_INCREMENT PRIMARY KEY,
    vc_document_type ENUM('CC','CE','TI','PASSPORT') NOT NULL,
    vc_document_number VARCHAR(20) NOT NULL UNIQUE,
    vc_first_name VARCHAR(50) NOT NULL,
    vc_last_name VARCHAR(50) NOT NULL,
    vc_birth_date DATE NOT NULL,
    vc_gender ENUM('M','F','O') NOT NULL,
    vc_phone VARCHAR(20),
    vc_email VARCHAR(100),
    vc_address VARCHAR(200),
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Información laboral del empleado
CREATE TABLE employee_records (
    vn_employee_id INT AUTO_INCREMENT PRIMARY KEY,
    vn_person_id INT NOT NULL,
    vn_role_id INT,
    vc_hire_date DATE NOT NULL,
    vc_bank_account VARCHAR(30),
    vc_bank_name VARCHAR(100),
    vc_account_type ENUM('SAVINGS','CHECKING') DEFAULT 'SAVINGS',
    vc_status ENUM('ACTIVE','INACTIVE','SUSPENDED','TERMINATED') DEFAULT 'ACTIVE',
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vn_person_id) REFERENCES personal_info(vn_person_id),
    FOREIGN KEY (vn_role_id) REFERENCES job_roles(vn_role_id)
);

-- Contratos laborales
CREATE TABLE employee_contracts (
    vn_contract_id INT AUTO_INCREMENT PRIMARY KEY,
    vn_employee_id INT NOT NULL,
    vn_mode_id INT NOT NULL,
    vc_start_date DATE NOT NULL,
    vc_end_date DATE,
    vn_monthly_salary DECIMAL(12,2) NOT NULL,
    vn_hours_week DECIMAL(5,2) DEFAULT 48.00,
    vc_terms TEXT,
    vc_status ENUM('ACTIVE','EXPIRED','TERMINATED') DEFAULT 'ACTIVE',
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vn_employee_id) REFERENCES employee_records(vn_employee_id),
    FOREIGN KEY (vn_mode_id) REFERENCES contract_modes(vn_mode_id)
);

-- Parámetros del sistema
CREATE TABLE config_parameters (
    vn_param_id INT AUTO_INCREMENT PRIMARY KEY,
    vc_param_key VARCHAR(100) NOT NULL UNIQUE,
    vc_param_value VARCHAR(255) NOT NULL,
    vc_description TEXT,
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Periodos de nómina
CREATE TABLE salary_periods (
    vn_period_id INT AUTO_INCREMENT PRIMARY KEY,
    vc_start_date DATE NOT NULL,
    vc_end_date DATE NOT NULL,
    vc_payment_date DATE NOT NULL,
    vc_status ENUM('OPEN','PROCESSING','CLOSED','PAID') DEFAULT 'OPEN',
    vc_description VARCHAR(100),
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Conceptos de nómina
CREATE TABLE salary_items (
    vn_item_id INT AUTO_INCREMENT PRIMARY KEY,
    vc_item_name VARCHAR(100) NOT NULL,
    vc_item_type ENUM('EARNING','DEDUCTION','PROVISION') NOT NULL,
    vc_calc_type ENUM('FIXED','PERCENTAGE','FORMULA') NOT NULL,
    vn_social_security BOOL DEFAULT FALSE,
    vn_parafiscal BOOL DEFAULT FALSE,
    vc_description TEXT,
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Nómina generada por empleado y periodo
CREATE TABLE payroll_records (
    vn_payroll_id INT AUTO_INCREMENT PRIMARY KEY,
    vn_employee_id INT NOT NULL,
    vn_period_id INT NOT NULL,
    vn_contract_id INT NOT NULL,
    vn_salary_base DECIMAL(12,2) NOT NULL,
    vn_days_worked INT NOT NULL,
    vn_total_earnings DECIMAL(12,2) NOT NULL,
    vn_total_deductions DECIMAL(12,2) NOT NULL,
    vn_net_pay DECIMAL(12,2) NOT NULL,
    vc_status ENUM('DRAFT','APPROVED','PAID') DEFAULT 'DRAFT',
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vn_employee_id) REFERENCES employee_records(vn_employee_id),
    FOREIGN KEY (vn_period_id) REFERENCES salary_periods(vn_period_id),
    FOREIGN KEY (vn_contract_id) REFERENCES employee_contracts(vn_contract_id)
);

-- Detalles de conceptos de nómina
CREATE TABLE payroll_movements (
    vn_movement_id INT AUTO_INCREMENT PRIMARY KEY,
    vn_payroll_id INT NOT NULL,
    vn_item_id INT NOT NULL,
    vn_amount DECIMAL(12,2) NOT NULL,
    vc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vc_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vn_payroll_id) REFERENCES payroll_records(vn_payroll_id),
    FOREIGN KEY (vn_item_id) REFERENCES salary_items(vn_item_id)
);




-- 1. org_areas
INSERT INTO org_areas (vn_area_id, vc_area_name, vc_area_desc) VALUES
(1, 'Gestión Humana', 'Área encargada del talento humano'),
(2, 'Tesorería', 'Manejo financiero y presupuestal'),
(3, 'Administración', 'Gestión general del funcionamiento interno'),
(4, 'Sistemas', 'Responsable del soporte tecnológico'),
(5, 'Compras', 'Adquisición de bienes y servicios'),
(6, 'Logística', 'Manejo de inventarios y distribución'),
(7, 'Mercadeo', 'Promoción y posicionamiento de marca'),
(8, 'Ventas', 'Gestión comercial y atención al cliente'),
(9, 'Calidad', 'Control y mejora continua'),
(10, 'Servicio al Cliente', 'Atención postventa y soporte'),
(11, 'Producción', 'Fabricación de productos'),
(12, 'Innovación', 'Desarrollo de nuevos productos o servicios'),
(13, 'Auditoría Interna', 'Evaluación de procesos internos'),
(14, 'Legal', 'Cumplimiento normativo y asesoría jurídica'),
(15, 'Seguridad Industrial', 'Prevención de riesgos laborales');


-- 2. job_roles
INSERT INTO job_roles (vn_role_id, vc_role_name, vn_area_id, vn_base_salary, vc_description) VALUES
(1, 'Especialista de Nómina', 1, 3000000.00, 'Responsable de liquidación de nómina'),
(2, 'Contador General', 2, 3500000.00, 'Manejo contable y estados financieros'),
(3, 'Jefe de Administración', 3, 4000000.00, 'Supervisión de operaciones internas'),
(4, 'Analista de Sistemas', 4, 4200000.00, 'Soporte técnico y desarrollo'),
(5, 'Asistente de Compras', 5, 2800000.00, 'Apoyo en adquisiciones'),
(6, 'Coordinador Logístico', 6, 3800000.00, 'Organización de inventario y envíos'),
(7, 'Gerente de Mercadeo', 7, 5000000.00, 'Planeación estratégica de marketing'),
(8, 'Ejecutivo de Ventas', 8, 3200000.00, 'Cierre de negociaciones comerciales'),
(9, 'Técnico en Calidad', 9, 2900000.00, 'Control de estándares de producción'),
(10, 'Asesor de Servicio al Cliente', 10, 2700000.00, 'Soporte telefónico y presencial'),
(11, 'Operario de Producción', 11, 2600000.00, 'Trabajo en línea de fabricación'),
(12, 'Innovador Tecnológico', 12, 4500000.00, 'Investigación y desarrollo'),
(13, 'Auditor Interno', 13, 4300000.00, 'Revisión de cumplimientos internos'),
(14, 'Abogado Corporativo', 14, 4800000.00, 'Asesoría legal empresarial'),
(15, 'Ingeniero de Seguridad', 15, 4100000.00, 'Prevención de accidentes laborales');



-- 3. contract_modes
INSERT INTO contract_modes (vn_mode_id, vc_mode_name, vc_description) VALUES
(1, 'Contrato indefinido', 'Sin fecha de finalización'),
(2, 'Contrato a término fijo', 'Duración determinada'),
(3, 'Contrato por obra o labor', 'Por proyecto específico'),
(4, 'Contrato ocasional', 'Actividades no permanentes'),
(5, 'Contrato de aprendizaje', 'Formación profesional con práctica'),
(6, 'Contrato civil', 'Relación no laboral'),
(7, 'Contrato de servicios', 'Prestación independiente'),
(8, 'Contrato de tiempo parcial', 'Menor jornada laboral'),
(9, 'Contrato remoto', 'Trabajo desde fuera de oficinas'),
(10, 'Contrato temporal', 'Para cubrir vacaciones o permisos'),
(11, 'Contrato de jubilación flexible', 'Retorno parcial tras retiro'),
(12, 'Contrato de voluntariado', 'Sin ánimo de lucro'),
(13, 'Contrato de alta dirección', 'Directivos y gerentes'),
(14, 'Contrato de teletrabajo', 'Trabajo desde casa'),
(15, 'Contrato de prácticas', 'Estudiantes en formación');


-- 4. personal_info
INSERT INTO personal_info (
    vn_person_id, vc_document_type, vc_document_number, vc_first_name, vc_last_name,
    vc_birth_date, vc_gender, vc_phone, vc_email, vc_address
) VALUES
(1, 'CC', '12345678', 'Carlos', 'Gómez', '1990-04-25', 'M', '3001234567', 'carlos@example.com', 'Calle 123'),
(2, 'CC', '87654321', 'Laura', 'Martínez', '1985-11-12', 'F', '3017654321', 'laura@example.com', 'Carrera 45'),
(3, 'CC', '23456789', 'Andrés', 'López', '1992-07-15', 'M', '3109876543', 'andres@example.com', 'Diagonal 56'),
(4, 'TI', '34567890', 'Sofía', 'Ramírez', '2000-03-10', 'F', '3118765432', 'sofia@example.com', 'Avenida 78'),
(5, 'CC', '45678901', 'Camilo', 'Torres', '1988-09-05', 'M', '3127654321', 'camilo@example.com', 'Carrera 12'),
(6, 'CC', '56789012', 'Valentina', 'Rojas', '1995-01-22', 'F', '3136543210', 'valentina@example.com', 'Calle 45'),
(7, 'TI', '67890123', 'Sebastián', 'Mendoza', '1999-12-18', 'M', '3145432109', 'sebastian@example.com', 'Transversal 89'),
(8, 'CC', '78901234', 'Daniela', 'Ortiz', '1983-06-30', 'F', '3154321098', 'daniela@example.com', 'Plaza Mayor'),
(9, 'CC', '89012345', 'Mateo', 'Castaño', '1994-02-14', 'M', '3163210987', 'mateo@example.com', 'Callejón 34'),
(10, 'TI', '90123456', 'Isabella', 'Vargas', '2001-05-09', 'F', '3172109876', 'isabella@example.com', 'Avenida Norte'),
(11, 'CC', '91234567', 'Juan', 'Pérez', '1991-08-27', 'M', '3181098765', 'juan@example.com', 'Barrio San José'),
(12, 'CC', '92345678', 'Lucía', 'García', '1997-11-03', 'F', '3190987654', 'lucia@example.com', 'Urbanización Las Palmas'),
(13, 'TI', '93456789', 'David', 'Flores', '1989-04-19', 'M', '3209876543', 'david@example.com', 'Cra 10 #12-34'),
(14, 'CC', '94567890', 'Paula', 'Romero', '1996-10-17', 'F', '3218765432', 'paula@example.com', 'Calle 5 Sur'),
(15, 'CC', '95678901', 'Felipe', 'Duarte', '1993-03-11', 'M', '3227654321', 'felipe@example.com', 'Km 3 Vía Principal');

-- 5. employee_records
INSERT INTO employee_records (
    vn_employee_id, vn_person_id, vn_role_id, vc_hire_date,
    vc_bank_account, vc_bank_name, vc_account_type, vc_status
) VALUES
(1, 1, 1, '2022-01-10', '1234567890', 'Bancolombia', 'SAVINGS', 'ACTIVE'),
(2, 2, 2, '2021-06-01', '0987654321', 'Davivienda', 'CHECKING', 'ACTIVE'),
(3, 3, 3, '2020-03-15', '1122334455', 'Banco de Bogotá', 'CHECKING', 'ACTIVE'),
(4, 4, 4, '2021-09-01', '2233445566', 'Bancolombia', 'SAVINGS', 'ACTIVE'),
(5, 5, 5, '2022-02-14', '3344556677', 'Davivienda', 'CHECKING', 'ACTIVE'),
(6, 6, 6, '2023-01-20', '4455667788', 'Bancolombia', 'SAVINGS', 'ACTIVE'),
(7, 7, 7, '2019-07-05', '5566778899', 'BBVA', 'CHECKING', 'ACTIVE'),
(8, 8, 8, '2020-11-12', '6677889900', 'Banco Caja Social', 'SAVINGS', 'ACTIVE'),
(9, 9, 9, '2021-04-30', '7788990011', 'Bancolombia', 'CHECKING', 'ACTIVE'),
(10, 10, 10, '2022-08-22', '8899001122', 'Av Villas', 'SAVINGS', 'ACTIVE'),
(11, 11, 11, '2023-03-01', '9900112233', 'Bancolombia', 'CHECKING', 'ACTIVE'),
(12, 12, 12, '2020-06-18', '1011223344', 'Bancolombia', 'SAVINGS', 'ACTIVE'),
(13, 13, 13, '2021-12-10', '1112223344', 'Davivienda', 'CHECKING', 'ACTIVE'),
(14, 14, 14, '2022-05-25', '2223334455', 'Bancolombia', 'SAVINGS', 'ACTIVE'),
(15, 15, 15, '2023-02-15', '3334445566', 'BBVA', 'CHECKING', 'ACTIVE');

-- 6. employee_contracts
INSERT INTO employee_contracts (
    vn_contract_id, vn_employee_id, vn_mode_id, vc_start_date, vc_end_date,
    vn_monthly_salary, vn_hours_week, vc_terms, vc_status
) VALUES
(1, 1, 1, '2022-01-10', NULL, 3000000.00, 48.00, 'Contrato indefinido', 'ACTIVE'),
(2, 2, 2, '2021-06-01', '2023-06-01', 3500000.00, 48.00, 'Contrato fijo de 2 años', 'TERMINATED'),
(3, 3, 3, '2020-03-15', NULL, 4000000.00, 48.00, 'Contrato por obra', 'ACTIVE'),
(4, 4, 4, '2021-09-01', NULL, 4200000.00, 48.00, 'Contrato ocasional renovable', 'ACTIVE'),
(5, 5, 5, '2022-02-14', NULL, 2800000.00, 48.00, 'Contrato de aprendizaje', 'ACTIVE'),
(6, 6, 6, '2023-01-20', NULL, 3800000.00, 48.00, 'Contrato civil de servicios', 'ACTIVE'),
(7, 7, 7, '2019-07-05', '2022-07-05', 5000000.00, 48.00, 'Contrato de servicios por 3 años', 'TERMINATED'),
(8, 8, 8, '2020-11-12', NULL, 3200000.00, 48.00, 'Contrato indefinido', 'ACTIVE'),
(9, 9, 9, '2021-04-30', NULL, 2900000.00, 24.00, 'Contrato de tiempo parcial', 'ACTIVE'),
(10, 10, 10, '2022-08-22', NULL, 4500000.00, 48.00, 'Contrato indefinido', 'ACTIVE'),
(11, 11, 11, '2023-03-01', NULL, 4300000.00, 48.00, 'Contrato indefinido', 'ACTIVE'),
(12, 12, 12, '2020-06-18', NULL, 4800000.00, 48.00, 'Contrato indefinido', 'ACTIVE'),
(13, 13, 13, '2021-12-10', NULL, 4100000.00, 48.00, 'Contrato indefinido', 'ACTIVE'),
(14, 14, 14, '2022-05-25', NULL, 2700000.00, 48.00, 'Contrato indefinido', 'ACTIVE'),
(15, 15, 15, '2023-02-15', NULL, 2600000.00, 48.00, 'Contrato indefinido', 'ACTIVE');


-- 7. config_parameters
INSERT INTO config_parameters (vn_param_id, vc_param_key, vc_param_value, vc_description) VALUES
(1, 'min_salary', '1160000', 'Salario mínimo legal vigente 2023'),
(2, 'transport_allowance', '140606', 'Auxilio de transporte 2023'),
(3, 'overtime_rate', '1.25', 'Recargo por horas extras diurnas'),
(4, 'night_overtime_rate', '1.75', 'Recargo por horas extras nocturnas'),
(5, 'health_contribution', '0.04', 'Porcentaje aporte salud empleado'),
(6, 'pension_contribution', '0.04', 'Porcentaje aporte pensión empleado'),
(7, 'sena_rate', '0.02', 'Porcentaje para SENA'),
(8, 'icbf_rate', '0.03', 'Porcentaje para ICBF'),
(9, 'compensation_fund_rate', '0.04', 'Porcentaje para caja de compensación'),
(10, 'vacation_rate', '0.0833', 'Valor mensual de vacaciones'),
(11, 'prima_rate', '0.0833', 'Valor mensual de prima'),
(12, 'cesantias_rate', '0.0833', 'Valor anual de cesantías'),
(13, 'interest_cesantias_rate', '0.01', 'Intereses sobre cesantías'),
(14, 'arl_rate_low', '0.00522', 'Tarifa ARL riesgo 1'),
(15, 'arl_rate_high', '0.0696', 'Tarifa ARL riesgo 5');


-- 8. salary_periods
INSERT INTO salary_periods (vn_period_id, vc_start_date, vc_end_date, vc_payment_date, vc_description, vc_status) VALUES
(1, '2023-04-01', '2023-04-15', '2023-04-16', '1ra Quincena Abril', 'PAID'),
(2, '2023-04-16', '2023-04-30', '2023-05-01', '2da Quincena Abril', 'PAID'),
(3, '2023-05-01', '2023-05-15', '2023-05-16', '1ra Quincena Mayo', 'PAID'),
(4, '2023-05-16', '2023-05-31', '2023-06-01', '2da Quincena Mayo', 'OPEN'),
(5, '2023-06-01', '2023-06-15', '2023-06-16', '1ra Quincena Junio', 'OPEN'),
(6, '2023-06-16', '2023-06-30', '2023-07-01', '2da Quincena Junio', 'OPEN'),
(7, '2023-07-01', '2023-07-15', '2023-07-16', '1ra Quincena Julio', 'OPEN'),
(8, '2023-07-16', '2023-07-31', '2023-08-01', '2da Quincena Julio', 'OPEN'),
(9, '2023-08-01', '2023-08-15', '2023-08-16', '1ra Quincena Agosto', 'OPEN'),
(10, '2023-08-16', '2023-08-31', '2023-09-01', '2da Quincena Agosto', 'OPEN'),
(11, '2023-09-01', '2023-09-15', '2023-09-16', '1ra Quincena Septiembre', 'OPEN'),
(12, '2023-09-16', '2023-09-30', '2023-10-01', '2da Quincena Septiembre', 'OPEN'),
(13, '2023-10-01', '2023-10-15', '2023-10-16', '1ra Quincena Octubre', 'OPEN'),
(14, '2023-10-16', '2023-10-31', '2023-11-01', '2da Quincena Octubre', 'OPEN'),
(15, '2023-11-01', '2023-11-15', '2023-11-16', '1ra Quincena Noviembre', 'OPEN');


-- 9. salary_items
INSERT INTO salary_items (
    vn_item_id, vc_item_name, vc_item_type, vc_calc_type,
    vn_social_security, vn_parafiscal, vc_description
) VALUES
(1, 'Salario base', 'EARNING', 'FIXED', TRUE, TRUE, 'Pago mensual fijo'),
(2, 'Descuento Salud', 'DEDUCTION', 'PERCENTAGE', TRUE, FALSE, 'Aporte salud empleado'),
(3, 'Auxilio de transporte', 'EARNING', 'FIXED', TRUE, FALSE, 'Ayuda para movilización'),
(4, 'Horas extras', 'EARNING', 'PER_HOUR', TRUE, FALSE, 'Pago por horas adicionales'),
(5, 'Bonificación especial', 'EARNING', 'VARIABLE', FALSE, FALSE, 'Incentivo no obligatorio'),
(6, 'Prima legal', 'EARNING', 'ANNUAL', TRUE, FALSE, 'Prestación social anual'),
(7, 'Vacaciones', 'EARNING', 'ANNUAL', TRUE, FALSE, 'Descanso remunerado'),
(8, 'Cesantías', 'EARNING', 'ANNUAL', TRUE, FALSE, 'Ahorro obligatorio'),
(9, 'Intereses de cesantías', 'EARNING', 'ANNUAL', TRUE, FALSE, 'Rendimientos sobre cesantías'),
(10, 'Salud patronal', 'DEDUCTION', 'PERCENTAGE', TRUE, FALSE, 'Aporte empleador salud'),
(11, 'Pensión patronal', 'DEDUCTION', 'PERCENTAGE', TRUE, FALSE, 'Aporte empleador pensión'),
(12, 'SENA', 'DEDUCTION', 'PERCENTAGE', FALSE, TRUE, 'Contribución al SENA'),
(13, 'ICBF', 'DEDUCTION', 'PERCENTAGE', FALSE, TRUE, 'Contribución al ICBF'),
(14, 'Caja de compensación', 'DEDUCTION', 'PERCENTAGE', FALSE, TRUE, 'Aporte a caja de compensación'),
(15, 'Retención en la fuente', 'DEDUCTION', 'PERCENTAGE', FALSE, FALSE, 'Impuesto sobre ingresos');


-- 10. payroll_records
INSERT INTO payroll_records (
    vn_payroll_id, vn_employee_id, vn_period_id, vn_contract_id,
    vn_salary_base, vn_days_worked, vn_total_earnings, vn_total_deductions, vn_net_pay, vc_status
) VALUES
(1, 1, 1, 1, 3000000.00, 15, 1500000.00, 120000.00, 1380000.00, 'PAID'),
(2, 2, 1, 2, 3500000.00, 15, 1750000.00, 140000.00, 1610000.00, 'PAID'),
(3, 3, 2, 3, 4000000.00, 15, 2000000.00, 160000.00, 1840000.00, 'PAID'),
(4, 4, 2, 4, 4200000.00, 15, 2100000.00, 168000.00, 1932000.00, 'PAID'),
(5, 5, 3, 5, 2800000.00, 15, 1400000.00, 112000.00, 1288000.00, 'PROCESSING'),
(6, 6, 3, 6, 3800000.00, 15, 1900000.00, 152000.00, 1748000.00, 'PROCESSING'),
(7, 7, 3, 7, 5000000.00, 15, 2500000.00, 200000.00, 2300000.00, 'PROCESSING'),
(8, 8, 3, 8, 3200000.00, 15, 1600000.00, 128000.00, 1472000.00, 'PROCESSING'),
(9, 9, 3, 9, 2900000.00, 15, 1450000.00, 116000.00, 1334000.00, 'PROCESSING'),
(10, 10, 3, 10, 4500000.00, 15, 2250000.00, 180000.00, 2070000.00, 'PROCESSING'),
(11, 11, 3, 11, 4300000.00, 15, 2150000.00, 172000.00, 1978000.00, 'PROCESSING'),
(12, 12, 3, 12, 4800000.00, 15, 2400000.00, 192000.00, 2208000.00, 'PROCESSING'),
(13, 13, 3, 13, 4100000.00, 15, 2050000.00, 164000.00, 1886000.00, 'PROCESSING'),
(14, 14, 3, 14, 2700000.00, 15, 1350000.00, 108000.00, 1242000.00, 'PROCESSING'),
(15, 15, 3, 15, 2600000.00, 15, 1300000.00, 104000.00, 1196000.00, 'PROCESSING');


-- 11. payroll_movements
INSERT INTO payroll_movements (
    vn_movement_id, vn_payroll_id, vn_item_id, vn_amount
) VALUES
(1, 1, 1, 1500000.00),
(2, 1, 2, 120000.00),
(3, 2, 2, 140000.00),
(4, 3, 1, 2000000.00),
(5, 3, 2, 160000.00),
(6, 4, 1, 2100000.00),
(7, 4, 2, 168000.00),
(8, 5, 1, 1400000.00),
(9, 5, 2, 112000.00),
(10, 6, 1, 1900000.00),
(11, 6, 2, 152000.00),
(12, 7, 1, 2500000.00),
(13, 7, 2, 200000.00),
(14, 8, 1, 1600000.00),
(15, 8, 2, 128000.00);




DELIMITER $$

-- Procedimientos para 'org_areas'
CREATE PROCEDURE create_area(IN _vc_area_name VARCHAR(100), IN _vc_area_desc TEXT)
BEGIN
    INSERT INTO org_areas (vc_area_name, vc_area_desc)
    VALUES (_vc_area_name, _vc_area_desc);
END $$

CREATE PROCEDURE update_area(IN _vn_area_id INT, IN _vc_area_name VARCHAR(100), IN _vc_area_desc TEXT)
BEGIN
    UPDATE org_areas
    SET vc_area_name = _vc_area_name, vc_area_desc = _vc_area_desc
    WHERE vn_area_id = _vn_area_id;
END $$

CREATE PROCEDURE delete_area(IN _vn_area_id INT)
BEGIN
    DELETE FROM org_areas WHERE vn_area_id = _vn_area_id;
END $$

CREATE PROCEDURE get_area(IN _vn_area_id INT)
BEGIN
    SELECT * FROM org_areas WHERE vn_area_id = _vn_area_id;
END $$

-- Procedimientos para 'job_roles'
CREATE PROCEDURE create_job_role(IN _vc_role_name VARCHAR(100), IN _vn_area_id INT, IN _vn_base_salary DECIMAL(12,2), IN _vc_description TEXT)
BEGIN
    INSERT INTO job_roles (vc_role_name, vn_area_id, vn_base_salary, vc_description)
    VALUES (_vc_role_name, _vn_area_id, _vn_base_salary, _vc_description);
END $$

CREATE PROCEDURE update_job_role(IN _vn_role_id INT, IN _vc_role_name VARCHAR(100), IN _vn_area_id INT, IN _vn_base_salary DECIMAL(12,2), IN _vc_description TEXT)
BEGIN
    UPDATE job_roles
    SET vc_role_name = _vc_role_name, vn_area_id = _vn_area_id, vn_base_salary = _vn_base_salary, vc_description = _vc_description
    WHERE vn_role_id = _vn_role_id;
END $$

CREATE PROCEDURE delete_job_role(IN _vn_role_id INT)
BEGIN
    DELETE FROM job_roles WHERE vn_role_id = _vn_role_id;
END $$

CREATE PROCEDURE get_job_role(IN _vn_role_id INT)
BEGIN
    SELECT * FROM job_roles WHERE vn_role_id = _vn_role_id;
END $$

-- Procedimientos para 'contract_modes'
CREATE PROCEDURE create_contract_mode(IN _vc_mode_name VARCHAR(100), IN _vc_description TEXT)
BEGIN
    INSERT INTO contract_modes (vc_mode_name, vc_description)
    VALUES (_vc_mode_name, _vc_description);
END $$

CREATE PROCEDURE update_contract_mode(IN _vn_mode_id INT, IN _vc_mode_name VARCHAR(100), IN _vc_description TEXT)
BEGIN
    UPDATE contract_modes
    SET vc_mode_name = _vc_mode_name, vc_description = _vc_description
    WHERE vn_mode_id = _vn_mode_id;
END $$

CREATE PROCEDURE delete_contract_mode(IN _vn_mode_id INT)
BEGIN
    DELETE FROM contract_modes WHERE vn_mode_id = _vn_mode_id;
END $$

CREATE PROCEDURE get_contract_mode(IN _vn_mode_id INT)
BEGIN
    SELECT * FROM contract_modes WHERE vn_mode_id = _vn_mode_id;
END $$

-- Procedimientos para 'personal_info'
CREATE PROCEDURE create_person(
    IN _vc_document_type ENUM('CC','CE','TI','PASSPORT'),
    IN _vc_document_number VARCHAR(20),
    IN _vc_first_name VARCHAR(50),
    IN _vc_last_name VARCHAR(50),
    IN _vc_birth_date DATE,
    IN _vc_gender ENUM('M','F','O'),
    IN _vc_phone VARCHAR(20),
    IN _vc_email VARCHAR(100),
    IN _vc_address VARCHAR(200)
)
BEGIN
    INSERT INTO personal_info (
        vc_document_type, vc_document_number, vc_first_name, vc_last_name,
        vc_birth_date, vc_gender, vc_phone, vc_email, vc_address
    ) VALUES (
        _vc_document_type, _vc_document_number, _vc_first_name, _vc_last_name,
        _vc_birth_date, _vc_gender, _vc_phone, _vc_email, _vc_address
    );
END $$

CREATE PROCEDURE get_person(IN _vn_person_id INT)
BEGIN
    SELECT * FROM personal_info WHERE vn_person_id = _vn_person_id;
END $$

-- Procedimientos para 'employee_records'
CREATE PROCEDURE create_employee_record(
    IN _vn_person_id INT,
    IN _vn_role_id INT,
    IN _vc_hire_date DATE,
    IN _vc_bank_account VARCHAR(30),
    IN _vc_bank_name VARCHAR(100),
    IN _vc_account_type ENUM('SAVINGS','CHECKING'),
    IN _vc_status ENUM('ACTIVE','INACTIVE','SUSPENDED','TERMINATED')
)
BEGIN
    INSERT INTO employee_records (
        vn_person_id, vn_role_id, vc_hire_date,
        vc_bank_account, vc_bank_name, vc_account_type, vc_status
    ) VALUES (
        _vn_person_id, _vn_role_id, _vc_hire_date,
        _vc_bank_account, _vc_bank_name, _vc_account_type, _vc_status
    );
END $$

CREATE PROCEDURE get_employee_record(IN _vn_employee_id INT)
BEGIN
    SELECT * FROM employee_records WHERE vn_employee_id = _vn_employee_id;
END $$

-- Procedimientos para 'employee_contracts'
CREATE PROCEDURE create_employee_contract(
    IN _vn_employee_id INT,
    IN _vn_mode_id INT,
    IN _vc_start_date DATE,
    IN _vc_end_date DATE,
    IN _vn_monthly_salary DECIMAL(12,2),
    IN _vn_hours_week DECIMAL(5,2),
    IN _vc_terms TEXT,
    IN _vc_status ENUM('ACTIVE','EXPIRED','TERMINATED')
)
BEGIN
    DECLARE role_salary DECIMAL(12,2);
    
    -- Si no se proporciona salario, tomar el salario base del cargo
    IF _vn_monthly_salary IS NULL THEN
        SELECT vn_base_salary INTO role_salary
        FROM job_roles j
        JOIN employee_records e ON j.vn_role_id = e.vn_role_id
        WHERE e.vn_employee_id = _vn_employee_id;

        SET _vn_monthly_salary = role_salary;
    END IF;

    INSERT INTO employee_contracts (
        vn_employee_id, vn_mode_id, vc_start_date, vc_end_date,
        vn_monthly_salary, vn_hours_week, vc_terms, vc_status
    ) VALUES (
        _vn_employee_id, _vn_mode_id, _vc_start_date, _vc_end_date,
        _vn_monthly_salary, _vn_hours_week, _vc_terms, _vc_status
    );
END $$


CREATE PROCEDURE get_employee_contract(IN _vn_contract_id INT)
BEGIN
    SELECT * FROM employee_contracts WHERE vn_contract_id = _vn_contract_id;
END $$

-- Procedimientos para 'salary_periods'
CREATE PROCEDURE create_salary_period(
    IN _vc_start_date DATE,
    IN _vc_end_date DATE,
    IN _vc_payment_date DATE,
    IN _vc_description VARCHAR(100),
    IN _vc_status ENUM('OPEN','PROCESSING','CLOSED','PAID')
)
BEGIN
    INSERT INTO salary_periods (
        vc_start_date, vc_end_date, vc_payment_date, vc_description, vc_status
    ) VALUES (
        _vc_start_date, _vc_end_date, _vc_payment_date, _vc_description, _vc_status
    );
END $$

CREATE PROCEDURE get_salary_period(IN _vn_period_id INT)
BEGIN
    SELECT * FROM salary_periods WHERE vn_period_id = _vn_period_id;
END $$

-- Procedimientos para 'salary_items'
CREATE PROCEDURE create_salary_item(
    IN _vc_item_name VARCHAR(100),
    IN _vc_item_type ENUM('EARNING','DEDUCTION','PROVISION'),
    IN _vc_calc_type ENUM('FIXED','PERCENTAGE','FORMULA'),
    IN _vn_social_security BOOLEAN,
    IN _vn_parafiscal BOOLEAN,
    IN _vc_description TEXT
)
BEGIN
    INSERT INTO salary_items (
        vc_item_name, vc_item_type, vc_calc_type,
        vn_social_security, vn_parafiscal, vc_description
    ) VALUES (
        _vc_item_name, _vc_item_type, _vc_calc_type,
        _vn_social_security, _vn_parafiscal, _vc_description
    );
END $$

CREATE PROCEDURE get_salary_item(IN _vn_item_id INT)
BEGIN
    SELECT * FROM salary_items WHERE vn_item_id = _vn_item_id;
END $$

DELIMITER ;


