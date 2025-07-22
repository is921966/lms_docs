-- Create org_employees table
CREATE TABLE IF NOT EXISTS org_employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tab_number VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    position VARCHAR(255) NOT NULL,
    department_id UUID NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(30),
    user_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id) 
        REFERENCES departments(id)
        ON DELETE RESTRICT,
        
    CONSTRAINT fk_employee_user
        FOREIGN KEY (user_id) 
        REFERENCES users(id)
        ON DELETE SET NULL
);

-- Create indexes
CREATE INDEX idx_org_employees_tab_number ON org_employees(tab_number);
CREATE INDEX idx_org_employees_department_id ON org_employees(department_id);
CREATE INDEX idx_org_employees_user_id ON org_employees(user_id);
CREATE INDEX idx_org_employees_name ON org_employees(name);

-- Add trigger for updated_at
CREATE TRIGGER update_org_employees_updated_at 
    BEFORE UPDATE ON org_employees 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column(); 