-- ADDRESS TYPES
INSERT INTO public.address_types(address_type) VALUES ('Delivery Address') ON CONFLICT DO NOTHING;

-- CONTACT METHOD TYPES
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Tel') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Fax') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Cell') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Email') ON CONFLICT DO NOTHING;

-- ROLES
INSERT INTO roles (name) VALUES ('IMPLEMENTATION_OWNER') ON CONFLICT DO NOTHING;
INSERT INTO roles (name) VALUES ('TRANSPORTER') ON CONFLICT DO NOTHING;
INSERT INTO roles (name) VALUES ('OTHER') ON CONFLICT DO NOTHING;
INSERT INTO roles (name) VALUES ('CUSTOMER') ON CONFLICT DO NOTHING;
INSERT INTO roles (name) VALUES ('SUPPLIER') ON CONFLICT DO NOTHING;

-- UNITS OF MEASURE TYPE
INSERT INTO uom_types (code) VALUES ('INVENTORY') ON CONFLICT DO NOTHING;

-- LOCATION STORAGE TYPES
INSERT INTO location_storage_types (storage_type_code) VALUES('PALLETS') ON CONFLICT DO NOTHING;
INSERT INTO location_storage_types (storage_type_code) VALUES('RMT_PALLETS') ON CONFLICT DO NOTHING;
