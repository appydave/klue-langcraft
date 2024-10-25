# User Stories

## User Story 1: Submit DSL Request
**As a** user,  
**I want to** submit a DSL request with a valid JWT token,  
**so that** the server can process the request and store the received data.

## User Story 2: Store DSL Request with Source ID and Name
**As a** system,  
**I want to** store each DSL request with a `source_id` and a `name` (label) provided by the user,  
**so that** I can uniquely track requests even if the filename or contents change.

## User Story 3: Create New Record for Null Source ID
**As a** system,  
**I want to** create a new DSL request record when `source_id` is NULL,  
**so that** I can treat every submission as a new request.

## User Story 4: Track Creation and Update Timestamps
**As a** system,  
**I want to** store both `created_timestamp` and `updated_timestamp` for each DSL request,  
**so that** I can track when requests were initially created and when they were last updated.

## User Story 5: Log All Changes in an Audit Trail
**As a** system,  
**I want to** log every change to a DSL request, including updates to the `name` and `dsl_payload`,  
**so that** I can maintain a complete audit trail of the request's history.

## User Story 6: Create New Record for Different DSL Types
**As a** system,  
**I want to** create a new DSL request record when the `dsl_type` changes for the same `source_id`,  
**so that** I can track different types of requests even if they originate from the same file.

## User Story 7: Create New Record for Different Source IDs
**As a** system,  
**I want to** create a new DSL request record when the `source_id` changes (even for the same DSL type),  
**so that** I can handle changes in file contents or structure.

## User Story 8: Track Processing Status
**As a** system,  
**I want to** track the status of each processing step (validation, generation, etc.) for each DSL request,  
**so that** I can monitor whether the processing was successful, failed, or incomplete.

## User Story 9: Retrieve Processed DSL Data
**As a** user,  
**I want to** retrieve the result of a processed DSL request,  
**so that** I can see what actions were taken or if there were any errors.
