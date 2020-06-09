ALTER TABLE mr_bulk_stock_adjustments
ALTER COLUMN integrated_at TYPE timestamp with time zone;

UPDATE mr_bulk_stock_adjustments
SET integrated_at = integrated_at - 2;