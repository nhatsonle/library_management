-- Tạo Roles
CREATE ROLE UserRole;
CREATE ROLE StaffRole;

-- Cấp quyền cho UserRole
GRANT UPDATE ON users TO UserRole;
GRANT SELECT ON books TO UserRole;
GRANT SELECT,INSERT ON read TO UserRole;

-- Cấp quyền cho StaffRole
GRANT INSERT, UPDATE ON staff TO StaffRole;
GRANT SELECT,INSERT,UPDATE,DELETE ON books,re,report,authors TO StaffRole;
GRANT SELECT ON users TO StaffRole;












