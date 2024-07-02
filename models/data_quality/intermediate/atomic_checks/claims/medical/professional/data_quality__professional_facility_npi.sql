{{ config(
    enabled = var('claims_enabled', False)
) }}

WITH BASE as (
    SELECT * 
    FROM {{ ref('medical_claim')}}
    WHERE CLAIM_TYPE = 'professional'
)

SELECT
    M.Data_SOURCE
    ,coalesce(cast(M.CLAIM_START_DATE as varchar(50)),cast('1900-01-01' as varchar(10))) AS SOURCE_DATE
    ,'MEDICAL_CLAIM' AS TABLE_NAME
    ,'Claim ID | Claim Line Number' AS DRILL_DOWN_KEY
    ,CONCAT(COALESCE(CAST(M.CLAIM_ID AS VARCHAR), 'NULL'),'|',COALESCE(CAST(M.CLAIM_LINE_NUMBER AS VARCHAR), 'NULL')) AS DRILL_DOWN_VALUE
    ,'professional' AS CLAIM_TYPE
    ,'FACILITY_NPI' AS FIELD_NAME
    ,case when TERM.NPI is not null          then        'valid'
          when M.FACILITY_NPI is not null    then 'invalid'      
                                             else 'null' end as BUCKET_NAME
    ,case
        when M.FACILITY_NPI is not null
            and term.npi is null
            then 'Facility NPI does not join to Terminology Provider Table'
        else null
    end as INVALID_REASON
    ,CAST(M.FACILITY_NPI AS VARCHAR(255)) AS FIELD_VALUE
    , '{{ var('tuva_last_run')}}' as tuva_last_run
FROM BASE M
LEFT JOIN {{ ref('terminology__provider')}} AS TERM ON M.FACILITY_NPI = TERM.NPI