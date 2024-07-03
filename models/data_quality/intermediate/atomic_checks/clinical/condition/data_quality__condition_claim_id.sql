{{ config(
    enabled = var('clinical_enabled', False)
) }}

SELECT
    M.Data_SOURCE
    ,coalesce(M.RECORDED_DATE,cast('1900-01-01' as date)) AS SOURCE_DATE
    ,'CONDITION' AS TABLE_NAME
    ,'Condition ID' as DRILL_DOWN_KEY
    , coalesce(condition_id, 'NULL') AS DRILL_DOWN_VALUE
    -- ,M.CLAIM_TYPE AS CLAIM_TYPE
    ,'CLAIM_ID' AS FIELD_NAME
    ,case when M.CLAIM_ID is not null then 'valid' else 'null' end as BUCKET_NAME
    ,cast(null as varchar(255)) as INVALID_REASON
    ,CAST(CLAIM_ID AS VARCHAR(255)) AS FIELD_VALUE
    , '{{ var('tuva_last_run')}}' as tuva_last_run
FROM {{ ref('condition')}} M