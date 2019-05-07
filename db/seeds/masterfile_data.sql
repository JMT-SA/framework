-- CONTACT METHOD TYPES
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Tel');
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Fax');
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Cell');
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Email');

-- ADDRESS TYPES
INSERT INTO public.address_types(address_type) VALUES ('Delivery Address');

-- ROLES
INSERT INTO roles (name) VALUES ('IMPLEMENTATION_OWNER');
INSERT INTO roles (name) VALUES ('TRANSPORTER');
INSERT INTO roles (name) VALUES ('OTHER');
INSERT INTO roles (name) VALUES ('CUSTOMER');
INSERT INTO roles (name) VALUES ('SUPPLIER');
