# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres roughly to [Semantic Versioning](http://semver.org/).


## [Unreleased]
### Added
### Changed
### Fixed

## [0.6.4] - 2019-09-06
### Added
- Message Bus to be able to push messages to the browser from the server.
### Changed
- Upgrade AG Grid to version 21.

## [0.6.3] - 2019-07-11
### Added
- Deliveries can record qty returned.
- Oversupplied deliveries must be accepted before verify can be done.
### Changed
- Dataminer grids now share standard javascript grid logic.

## [0.6.2] - 2019-06-27
### Added
- Exceptions are emailed. The recipients and subject prefix can be configured.
- Inline editing for grids.
- Tables can have a column named `extended_columns` with JSONB key/values that can be displayed and edited.
- Added toggle camera scan route to RMD menu.
- RMD form: can lookup an id to display a value on the form.
- RMD form: a field can be set to submit the form on scan.
- User permissions stored in `permission_tree` on users table.
- EDI out process to update ERP system with Purchase Invoice prices handled by job queue.
- Use the `Choices` js library instead of the `Selectr` library to make `select` tags searchable. This lib works better on mobile devices.
### Changed
- Created RMD utilities route and moved check_barcode to it.

## [0.6.0] - 2019-02-01
### Added
- Maintain printers.
- Maintain printer applications and use them for selecting printers for barcode prints.
- Lookup control to select a row from a agrid for modifying input values in a form.
- FoldUp control for collapsing sections of a page.
- Complete/Approve etc state changes.
- Observers for Services.
- Shared label config - also used by Label designer.
- Label templates for printing labels.
### Changed
-Locations: location code became long_code, legacy_barcode became short_code and print_code was added.

## [0.5.0] - 2018-12-03
### Added
- Job queues using Que gem.
- Send email using the `Mail` gem. `config/mail_settings.rb` must be set up and a default sender address must be set up in the `.env.local` file for `SYSTEM_MAIL_SENDER`.
- Japser reports can be launched from the framework.
- Purchase Orders.
- Deliveries.
- Calculated columns for grids.
- RMD (Registered Mobile Devices) functionality for scanning on Android hardware.
- Log status functionality.
- Implementation Owner party.
- Document sequence rules for creating document serial numbers.
### Changed
- Roda::DataGrid update to the way list grids are defined (using Crossbeams::DataGrid::ListGridDefinition instead of calling layout's grid renderer).
- All fetch requests expect JSON responses. This mostly affects dialog-building responses which were returning HTML text. All `return_json_response` calls replaced by one in the main route.
- Grid rows can be coloured simply by providing a class in a column named `colour_rule`.
- Capture locations.
- AG Grid upgraded to 1.19.2.
- AppLoader for bootstrapping (the code was moved from framework.rb)

## [0.4.0] - 2018-08-10
### Changed
- All icon usage changed from using FontAwesome to using embedded SVG icons.

## [0.3.0] - 2018-08-02
### Added
- Building Material Resource Products
### Changed
- Make user login case-insensitive.
- Removed initial Products build

## [0.2.0] - 2018-02-12
### Added
- This changelog.
### Changed
- Move to Ruby 2.5.
