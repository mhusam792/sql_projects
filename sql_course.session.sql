SELECT job_posted_date
FROM job_postings_fact 
LIMIT 10;

SELECT
    job_title_short as title, 
    job_location as location,
    job_posted_date::DATE as date 
FROM 
    job_postings_fact
LIMIT  
    10;

CREATE TABLE january_jobs AS 
    SELECT *
    FROM
        job_postings_fact
    WHERE
        EXTRACT(YEAR FROM job_posted_date) = 2023 And
        EXTRACT(Month from job_posted_date) = 1;

CREATE TABLE february_jobs AS 
    SELECT *
    FROM
        job_postings_fact
    WHERE
        EXTRACT(YEAR FROM job_posted_date) = 2023 AND
        EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS 
    SELECT *
    FROM
        job_postings_fact
    WHERE
        EXTRACT(YEAR FROM job_posted_date) = 2023 AND
        EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT * 
FROM february_jobs
LIMIT 10;

SELECT 
    count(job_id) as number_of_jobs, 
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_categroy
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_categroy
order by number_of_jobs desc;

-- practice problem
SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN salary_year_avg BETWEEN 0 And 50000 THEN '0-50k'
        WHEN salary_year_avg BETWEEN 51000 And 100000 THEN '51-100k'
        WHEN salary_year_avg BETWEEN 100001 And 150000 THEN '101-150k'
        ELSE '> 150K'
    END AS yearly_salaries
FROM
    job_postings_fact
WHERE
    Not salary_year_avg IS NULL
    AND job_title_short = 'Data Analyst'
GROUP BY yearly_salaries
ORDER BY number_of_jobs;

WITH january_jobs AS ( -- CTE definition starts here
	SELECT *
	FROM 
		job_postings_fact
	WHERE 
		EXTRACT(MONTH FROM job_posted_date) = 1
) -- CTE definition ends here

SELECT * 
FROM january_jobs;

SELECT 
    company_id, 
    name AS company_name
FROM 
    company_dim
WHERE
    company_id IN (
        SELECT 
            company_id
        FROM 
            job_postings_fact
        WHERE
            job_no_degree_mention = true
            )
ORDER BY company_id;

SELECT
    company_id,
    name as company_name
FROM 
    company_dim

WITH company_job_count AS ( 
    SELECT 
        company_id,
        COUNT(*) AS job_count
    FROM
        job_postings_fact
    GROUP BY 
        company_id
)

select * from company_job_count;

WITH company_job_count AS ( 
    SELECT 
        company_id,
        COUNT(*)
    FROM
        job_postings_fact
    GROUP BY 
        company_id
)

select * from company_job_count;

SELECT 
    job_count.company_id,
    companies.name,
    count(job_count.company_id) as posting_number
FROM
    company_job_count as job_count 
    LEFT JOIN company_dim as companies
    ON job_count.company_id = companies.company_id
GROUP BY companies.name

select name
from company_dim
left join company_job_count on company_job_count.company_id = company_dim.company_id;

SELECT
    companies.company_id,
    companies.name,
    count(*) as total_jobs
FROM 
    company_dim as companies
    LEFT JOIN job_postings_fact as job_postings
    on companies.company_id = job_postings.company_id
GROUP BY companies.company_id
ORDER BY 
    total_jobs DESC;

SELECT 
    skills.skill_id, 
    skills.skills, 
    count(skills.skill_id) as total_number_posting
FROM 
    job_postings_fact as job_postings
    LEFT JOIN skills_job_dim as skills_job
    ON job_postings.job_id = skills_job.job_id
    LEFT JOIN skills_dim as skills 
    ON skills_job.skill_id = skills.skill_id
WHERE
    job_postings.job_work_from_home = true AND
    job_postings.job_title_short LIKE 'Data Scientist'
GROUP BY 
    skills.skill_id
ORDER BY 
    total_number_posting DESC
LIMIT 5;

-- UNION 
-- Problem 8
WITH first_quarter_2023 as (
    SELECT 
        *
    FROM
        january_jobs

    UNION ALL

    SELECT 
        *
    FROM
        february_jobs
        
    UNION ALL

    SELECT 
        *
    FROM
        march_jobs
)

select
    job_title_short,
    job_location, 
    job_location,
    job_posted_date::DATE,
    salary_year_avg
from 
    first_quarter_2023
WHERE
    salary_year_avg > 70000 AND
    job_title_short = 'Data Analyst'
ORDER BY 
    salary_year_avg DESC;


