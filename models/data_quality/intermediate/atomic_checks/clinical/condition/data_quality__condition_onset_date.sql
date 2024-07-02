{{ config(
    enabled = var('clinical_enabled', False)
) }}

SELECT
    M.Data_SOURCE
    ,coalesce(M.RECORDED_DATE,cast('1900-01-01' as date)) AS SOURCE_DATE
    ,'CONDITION' AS TABLE_NAME
    ,'Condition ID' as DRILL_DOWN_KEY
    ,IFNULL(CONDITION_ID, 'NULL') AS DRILL_DOWN_VALUE
    -- ,M.CLAIM_TYPE AS CLAIM_TYPE
    ,'ONSET_DATE' AS FIELD_NAME
    ,CASE 
        WHEN M.ONSET_DATE > '{{ var('tuva_last_run') }}' THEN 'invalid'
        WHEN M.ONSET_DATE <= cast('1901-01-01' as date) THEN 'invalid'
        WHEN M.ONSET_DATE > M.RESOLVED_DATE THEN 'invalid'
        WHEN M.ONSET_DATE IS NULL THEN 'null'
        ELSE 'valid' 
    END AS BUCKET_NAME
    ,CASE 
        WHEN M.ONSET_DATE > '{{ var('tuva_last_run') }}' THEN 'future'
        WHEN M.ONSET_DATE <= cast('1901-01-01' as date) THEN 'too old'
        WHEN M.ONSET_DATE < M.RESOLVED_DATE THEN 'Onset date after resolved date'
        else null
    END AS INVALID_REASON
    ,CAST(ONSET_DATE AS VARCHAR(255)) AS FIELD_VALUE
    , '{{ var('tuva_last_run')}}' as tuva_last_run
FROM {{ ref('condition')}} M