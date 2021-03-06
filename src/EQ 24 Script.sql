USE [EdFi_Ods]
GO
/****** Object:  UserDefinedFunction [bi].[eq24.YearStart]    Script Date: 4/28/2020 12:37:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [bi].[eq24.YearStart]()
RETURNS @return TABLE ([YearStart] INT)
AS
BEGIN
  DECLARE @year char(20);
  IF month(getdate()) > 6  SET @year = year(getdate()) else SET @year = year(getdate()) - 1
  INSERT INTO @return SELECT @year;
  RETURN;
END;
GO
/****** Object:  View [bi].[eq24.StudentSchoolAssociation]    Script Date: 4/28/2020 12:37:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  View [BI].[eq24.EducationOrganization]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [BI].[eq24.EducationOrganization] 

AS

SELECT eo.[EducationOrganizationId]
      ,''[StateOrganizationId]
      ,eo.[NameOfInstitution]
	  ,s.[LocalEducationAgencyId]
FROM [edfi].[EducationOrganization] eo
LEFT JOIN [edfi].[School] s ON eo.EducationOrganizationId = s.SchoolId
GO
/****** Object:  View [BI].[eq24.Grade]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BI].[eq24.Grade] 

AS

SELECT 
	g.[StudentUSI]
	,G.[BeginDate] AS GradingPeriodBeginDate
	,'' AS Term
	,d.ShortDescription AS GradingPeriod
	,g.[SchoolId]
	,'' AS ClassPeriodName
	,g.[SchoolYear]
	,g.[LocalCourseCode]
	,'' AS UniqueSectionCode  
	,g.BeginDate
	,LocationClassroomIdentificationCode AS ClassroomIdentificationCode
	,s2.SequenceOfCourse AS SequenceOfCourse
	,(CASE WHEN CAST(g.NumericGradeEarned AS VARCHAR(10)) IS NULL THEN g.LetterGradeEarned ELSE CAST(g.NumericGradeEarned AS VARCHAR(10)) END) AS GradeEarned
	,gt.ShortDescription AS GradeType
	,s.LocalEducationAgencyId
FROM [edfi].[Grade] g
LEFT JOIN edfi.Section s2
ON s2.LocalCourseCode = g.LocalCourseCode
AND s2.LocationSchoolId = g.SchoolId
AND s2.SchoolYear = g.SchoolYear
AND s2.SectionIdentifier = g.SectionIdentifier
AND s2.SessionName = g.SessionName  
LEFT JOIN [edfi].[Descriptor] d ON g.GradingPeriodDescriptorId = d.DescriptorId
LEFT JOIN [edfi].[Descriptor] gt ON g.GradeTypeDescriptorId = gt.DescriptorId
LEFT JOIN [edfi].[School] s ON g.SchoolId = s.SchoolId
--LEFT JOIN [edfi].[Descriptor] d2 ON g.TermDescriptorId = d2.DescriptorId

--WHERE    SUBSTRING(g.LocalCourseCode,11,2) in ( '12') --this filter selects math courses only for Florida districts.
   
GO
/****** Object:  View [BI].[eq24.iReady_StudentAssessmentReportingMethod]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BI].[eq24.iReady_StudentAssessmentReportingMethod]

AS

SELECT  sa.[AssessmentIdentifier]
      ,sa.[StudentAssessmentIdentifier]
      ,sa.[StudentUSI]
      ,CAST([AdministrationDate] AS DATE) AS AdministrationDate
	  ,d.CodeValue AS WhenAssessedGradeLevel
	  ,d2.CodeValue AS AcademicSubject
	  ,armt.CodeValue AS AssessmentReportingMethod
	  ,a.AssessmentTitle
	  ,sasr.Result
	  ,'' Version
	  ,sasr.Namespace
  FROM [edfi].[StudentAssessment] sa
  LEFT JOIN  [edfi].[StudentAssessmentScoreResult] sasr on  sasr.StudentUSI = sa.StudentUSI 
										   and sasr.StudentAssessmentIdentifier = sa.StudentAssessmentIdentifier 
										  and sasr.AssessmentIdentifier = sa.AssessmentIdentifier 
										  and sasr.Namespace = sa.Namespace
  LEFT JOIN [edfi].[Assessment] a on sa.AssessmentIdentifier = a.AssessmentIdentifier
                                          and sa.Namespace = a.Namespace
  LEFT JOIN [edfi].[AssessmentAcademicSubject] aas on sa.AssessmentIdentifier = aas.AssessmentIdentifier and sa.Namespace = aas.Namespace
  LEFT JOIN [edfi].[Descriptor] d2 on aas.AcademicSubjectDescriptorId = d2.DescriptorId 
  LEFT JOIN [edfi].Descriptor armt on sasr.AssessmentReportingMethodDescriptorId = armt.DescriptorId
  LEFT JOIN [edfi].[Descriptor] d on sa.WhenAssessedGradeLevelDescriptorId = d.DescriptorId

  WHERE /*sasr.Namespace = 'http://www.curriculumassociates.com/Descriptor/Assessment.xml' 
    AND d2.CodeValue = 'Mathematics' 
	AND*/ armt.CodeValue <> 'Scale score'
                     
GO
/****** Object:  View [BI].[eq24.iReady_StudentAssessmentScoreResult]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BI].[eq24.iReady_StudentAssessmentScoreResult]

AS

SELECT  sa.[AssessmentIdentifier]
      ,sa.[StudentAssessmentIdentifier]
      ,sa.[StudentUSI]
      ,CAST([AdministrationDate] AS DATE) AS AdministrationDate	  
	  ,CAST([AdministrationEndDate] AS DATE) AS AdministrationEndDate
	  ,d.CodeValue AS WhenAssessedGradeLevel
	  ,d2.CodeValue AS AcademicSubject
	  ,armt.CodeValue AS AssessmentReportingMethod
	  ,a.AssessmentTitle
	  ,sasr.Result
	  ,'' Version
	  ,sasr.Namespace
  FROM [edfi].[StudentAssessment] sa
  LEFT JOIN  [edfi].[StudentAssessmentScoreResult] sasr on  sasr.StudentUSI = sa.StudentUSI 
										   and sasr.StudentAssessmentIdentifier = sa.StudentAssessmentIdentifier 
										  and sasr.AssessmentIdentifier = sa.AssessmentIdentifier 
										  and sasr.Namespace = sa.Namespace
  LEFT JOIN [edfi].[Assessment] a on sa.AssessmentIdentifier = a.AssessmentIdentifier
                                          and sa.Namespace = a.Namespace
  LEFT JOIN [edfi].[AssessmentAcademicSubject] aas on sa.AssessmentIdentifier = aas.AssessmentIdentifier and sa.Namespace = aas.Namespace
  LEFT JOIN [edfi].[Descriptor] d2 on aas.AcademicSubjectDescriptorId = d2.DescriptorId 
  LEFT JOIN [edfi].Descriptor armt on sasr.AssessmentReportingMethodDescriptorId = armt.DescriptorId
  LEFT JOIN [edfi].[Descriptor] d on sa.WhenAssessedGradeLevelDescriptorId = d.DescriptorId

  WHERE /*sasr.Namespace = 'http://www.curriculumassociates.com/Descriptor/Assessment.xml' 
    AND d2.CodeValue = 'Mathematics'  
	AND*/ armt.CodeValue = 'Scale score'
	
        
GO
/****** Object:  View [BI].[eq24.iReady_StudentAssessmentStudentObjectiveAssessmentPerformanceLevel]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [BI].[eq24.iReady_StudentAssessmentStudentObjectiveAssessmentPerformanceLevel]

AS

SELECT sasoasr.[AssessmentIdentifier]
      ,armt.[DescriptioN] AS ReportingMethod
      ,sasoasr.[IdentificationCode]
	  ,OA.Description AS ObjejctiveDescription
      ,sasoasr.[Namespace]
      ,[StudentAssessmentIdentifier]
      ,sasoasr.[StudentUSI]
      ,[Result]
      ,rdt.Description AS ResultDatatype
	 
FROM [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult] sasoasr
  LEFT JOIN [edfi].Descriptor armt ON sasoasr.AssessmentReportingMethodDescriptorId = armt.DescriptorId
  LEFT JOIN [edfi].Descriptor rdt ON sasoasr.ResultDatatypeTypeDescriptorId = rdt.DescriptorId
  LEFT JOIN [edfi].[ObjectiveAssessment] oa ON sasoasr.AssessmentIdentifier = oa.AssessmentIdentifier 
                                            AND sasoasr.Namespace = oa.Namespace
											AND sasoasr.IdentificationCode = oa.IdentificationCode
LEFT JOIN [edfi].[ObjectiveAssessmentPerformanceLevel] oapl ON sasoasr.AssessmentIdentifier = oapl.AssessmentIdentifier
														AND sasoasr.Namespace = oapl.Namespace
														AND sasoasr.IdentificationCode = oapl.IdentificationCode
														AND sasoasr.Result <= oapl.MaximumScore
														AND sasoasr.Result >= oapl.MinimumScore
LEFT JOIN [edfi].[Descriptor] d on oapl.PerformanceLevelDescriptorId = d.DescriptorId
LEFT JOIN [edfi].[ObjectiveAssessmentLearningStandard] oals ON oals.AssessmentIdentifier = sasoasr.AssessmentIdentifier
                                                        AND oals.IdentificationCode = sasoasr.IdentificationCode
														AND oals.Namespace = sasoasr.Namespace
LEFT JOIN [edfi].[LearningStandard] ls ON ls.LearningStandardId = oals.LearningStandardId

WHERE /*sasoasr.Namespace like 'http://www.curriculumassociates.com%'
		AND */ rdt.Description like 'Level'
	
GO
/****** Object:  View [BI].[eq24.iReady_StudentAssessmentStudentObjectiveAssessmentScoreResult]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [BI].[eq24.iReady_StudentAssessmentStudentObjectiveAssessmentScoreResult]

AS

SELECT sasoasr.[AssessmentIdentifier]
      ,armt.[DescriptioN] AS ReportingMethod
      ,sasoasr.[IdentificationCode]
	  ,OA.Description AS ObjectiveDescription
      ,sasoasr.[Namespace]
      ,[StudentAssessmentIdentifier]
      ,sasoasr.[StudentUSI]
      ,[Result]
      ,rdt.[DescriptioN] AS ResultDatatype
	 
FROM [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult] sasoasr
  LEFT JOIN [edfi].[Descriptor] armt ON sasoasr.AssessmentReportingMethodDescriptorId = armt.DescriptorId
  LEFT JOIN [edfi].[Descriptor] rdt ON sasoasr.ResultDatatypeTypeDescriptorId = rdt.DescriptorId
  LEFT JOIN [edfi].[ObjectiveAssessment] oa ON sasoasr.AssessmentIdentifier = oa.AssessmentIdentifier 
                                            AND sasoasr.Namespace = oa.Namespace
											AND sasoasr.IdentificationCode = oa.IdentificationCode
LEFT JOIN [edfi].[ObjectiveAssessmentPerformanceLevel] oapl ON sasoasr.AssessmentIdentifier = oapl.AssessmentIdentifier
														AND sasoasr.Namespace = oapl.Namespace
														AND sasoasr.IdentificationCode = oapl.IdentificationCode
														AND sasoasr.Result <= oapl.MaximumScore
														AND sasoasr.Result >= oapl.MinimumScore
LEFT JOIN [edfi].[Descriptor] d on oapl.PerformanceLevelDescriptorId = d.DescriptorId
LEFT JOIN [edfi].[ObjectiveAssessmentLearningStandard] oals ON oals.AssessmentIdentifier = sasoasr.AssessmentIdentifier
                                                        AND oals.IdentificationCode = sasoasr.IdentificationCode
														AND oals.Namespace = sasoasr.Namespace
LEFT JOIN [edfi].[LearningStandard] ls ON ls.LearningStandardId = oals.LearningStandardId

--WHERE sasoasr.Namespace like 'http://www.curriculumassociates.com%' 
--		AND rdt.Description like 'Integer'
GO
/****** Object:  View [BI].[eq24.MC_ObjectiveAssessmentPerformanceLevel]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BI].[eq24.MC_ObjectiveAssessmentPerformanceLevel]

AS

SELECT [AssessmentIdentifier]
      ,oapl.AssessmentReportingMethodDescriptorId [AssessmentReportingMethodTypeId]
      ,[IdentificationCode]
      ,oapl.Namespace
      ,oapl.[PerformanceLevelDescriptorId]
	  ,d.Description
      ,[MinimumScore]
      ,[MaximumScore]
      ,oapl.ResultDatatypeTypeDescriptorId [ResultDatatypeTypeId]
  FROM [edfi].[ObjectiveAssessmentPerformanceLevel] oapl
  LEFT JOIN [edfi].[Descriptor] d on oapl.PerformanceLevelDescriptorId = d.DescriptorId
  --WHERE oapl.Namespace = 'http://masteryconnect.com'
GO
/****** Object:  View [BI].[eq24.MC_StudentAssessmentScoreResult]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BI].[eq24.MC_StudentAssessmentScoreResult]

AS

SELECT  sa.[AssessmentIdentifier]
      ,sa.[StudentAssessmentIdentifier]
      ,sa.[StudentUSI]
      ,CAST([AdministrationDate] AS DATE) AS AdministrationDate
	  --,d3.CodeValue as GradeLevel
	  ,d2.CodeValue as AcademicSubject
	  ,sasr.AssessmentReportingMethodDescriptorId as AssessmentReportingMethodTypeId
	  ,a.AssessmentTitle
	  ,sasr.Result
	  ,'' Version
	  ,sasr.Namespace
  FROM [edfi].[StudentAssessment] sa
  LEFT JOIN  [edfi].[StudentAssessmentScoreResult] sasr on  sasr.StudentUSI = sa.StudentUSI 
										   and sasr.StudentAssessmentIdentifier = sa.StudentAssessmentIdentifier 
										  and sasr.AssessmentIdentifier = sa.AssessmentIdentifier 
										  and sasr.Namespace = sa.Namespace
  LEFT JOIN [edfi].[Assessment] a on sa.AssessmentIdentifier = a.AssessmentIdentifier
                                          and sa.Namespace = a.Namespace
  LEFT JOIN [edfi].[AssessmentAcademicSubject] aas on sa.AssessmentIdentifier = aas.AssessmentIdentifier and sa.Namespace = aas.Namespace
  LEFT JOIN [edfi].[Descriptor] d2 on aas.AcademicSubjectDescriptorId = d2.DescriptorId

  --WHERE sasr.Namespace = 'http://masteryconnect.com'
 
GO
/****** Object:  View [BI].[eq24.MC_StudentAssessmentStudentObjectiveAssessmentScoreResult]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [BI].[eq24.MC_StudentAssessmentStudentObjectiveAssessmentScoreResult]

AS

SELECT sasoasr.[AssessmentIdentifier]
      ,armt.[DescriptioN] AS ReportingMethod
      ,sasoasr.[IdentificationCode]
	  ,OA.Description AS ObjejctiveDescription
      ,sasoasr.[Namespace]
      ,[StudentAssessmentIdentifier]
      ,sasoasr.[StudentUSI]
      ,[Result]
	  ,oa.MaxRawScore
	  ,ls.LearningStandardItemCode
	  ,ls.Description AS LearningStandardDescription
	  ,d.Description AS PerformanceLevel
      ,rdt.Description AS ResultDatatype
	 
FROM [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult] sasoasr
  LEFT JOIN [edfi].Descriptor armt ON sasoasr.AssessmentReportingMethodDescriptorId = armt.DescriptorId
  LEFT JOIN [edfi].[Descriptor] rdt ON sasoasr.ResultDatatypeTypeDescriptorId = rdt.DescriptorId
  LEFT JOIN [edfi].[ObjectiveAssessment] oa ON sasoasr.AssessmentIdentifier = oa.AssessmentIdentifier 
                                            AND sasoasr.Namespace = oa.Namespace
											AND sasoasr.IdentificationCode = oa.IdentificationCode
LEFT JOIN [edfi].[ObjectiveAssessmentPerformanceLevel] oapl ON sasoasr.AssessmentIdentifier = oapl.AssessmentIdentifier
														AND sasoasr.Namespace = oapl.Namespace
														AND sasoasr.IdentificationCode = oapl.IdentificationCode
														AND sasoasr.Result <= oapl.MaximumScore
														AND sasoasr.Result >= oapl.MinimumScore
LEFT JOIN [edfi].[Descriptor] d on oapl.PerformanceLevelDescriptorId = d.DescriptorId
LEFT JOIN [edfi].[ObjectiveAssessmentLearningStandard] oals ON oals.AssessmentIdentifier = sasoasr.AssessmentIdentifier
                                                        AND oals.IdentificationCode = sasoasr.IdentificationCode
														AND oals.Namespace = sasoasr.Namespace
LEFT JOIN [edfi].[LearningStandard] ls ON ls.LearningStandardId = oals.LearningStandardId

WHERE sasoasr.Namespace = 'http://masteryconnect.com'
GO
/****** Object:  View [BI].[eq24.School]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BI].[eq24.School]

AS

SELECT s.[SchoolId]
      ,eo.NameOfInstitution AS SchoolName
      ,s.[LocalEducationAgencyId]
      ,s.SchoolTypeDescriptorId [SchoolTypeId]
	  ,st.CodeValue AS SchoolType
FROM [edfi].[School] s
LEFT JOIN edfi.Descriptor st ON s.SchoolTypeDescriptorId = st.DescriptorId
LEFT JOIN edfi.EducationOrganization eo ON s.SchoolId = eo.EducationOrganizationId

GO
/****** Object:  View [BI].[eq24.Section]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [BI].[eq24.Section]
AS

SELECT s.[SchoolId]
      ,''[ClassPeriodName]
      ,''[ClassroomIdentificationCode]
      ,[LocalCourseCode]
	  ,'' AS Term
      ,[SchoolYear]
      ,''[UniqueSectionCode]
      ,[SequenceOfCourse]
      ,EducationalEnvironmentDescriptorId AS [EducationalEnvironmentTypeId]
      ,[AvailableCredits]
	  ,sch.LocalEducationAgencyId
  FROM [edfi].[Section] s
  --LEFT JOIN [edfi].[Descriptor] d on s.TermDescriptorId = d.DescriptorId
  LEFT JOIN [edfi].[School] sch on s.SchoolId = sch.SchoolId
GO
/****** Object:  View [BI].[eq24.Staff]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [BI].[eq24.Staff]
AS

SELECT s.StaffUSI
      ,s.StaffUniqueId
	  ,s.PersonalTitlePrefix
      ,s.FirstName
      ,s.MiddleName
      ,s.LastSurname
	  ,s.GenerationCodeSuffix
      ,s.MaidenName
	  ,sem.ElectronicMailAddress
	  ,sa.StreetNumberName
	  ,sa.ApartmentRoomSuiteNumber
	  ,sa.City
	  ,sat.ShortDescription AS State
	  ,sa.PostalCode
      ,st.ShortDescription AS SexType
      ,s.BirthDate
	  ,(CASE WHEN RT.ShortDescription IS NULL THEN
              (CASE WHEN RaceDisp.Race IS NULL THEN 'Unknown' ELSE 'Multiracial' END)
              ELSE RT.[ShortDescription] END) AS RaceType
      ,s.HispanicLatinoEthnicity
	  ,s.OldEthnicityDescriptorId OldEthnicityTypeId
	  ,d.ShortDescription AS HighestCompletedLevelOfEducation
	  ,s.YearsOfPriorProfessionalExperience
	  ,s.YearsOfPriorTeachingExperience
      ,s.HighlyQualifiedTeacher
	  ,s.LoginId
      ,s.CitizenshipStatusDescriptorId CitizenshipStatusTypeId
  FROM          edfi.Staff                      AS s 
      LEFT JOIN edfi.Descriptor                    AS st  ON s.SexDescriptorId = st.DescriptorId
	  LEFT JOIN edfi.Descriptor                 AS d   ON s.HighestCompletedLevelOfEducationDescriptorId = d.DescriptorId
	  LEFT JOIN edfi.StaffElectronicMail        AS sem ON s.StaffUSI = sem.StaffUSI
	  LEFT JOIN edfi.StaffAddress               AS sa  ON s.StaffUSI = sa.StaffUSI
	  LEFT JOIN edfi.Descriptor      AS sat ON sa.StateAbbreviationDescriptorId = sat.DescriptorId
	  LEFT JOIN (SELECT DISTINCT t1.StaffUSI,
					  STUFF((SELECT cast(t2.RaceDescriptorID AS varchar(100))
						     FROM edfi.StaffRace t2
						     WHERE t2.StaffUSI = t1.StaffUSI
						     FOR XML PATH ('')
					       ),1,0,'') AS Race
				 FROM edfi.StaffRace t1
		        ) AS RaceDisp ON S.[StaffUSI] = RaceDisp.StaffUSI
	 LEFT JOIN edfi.Descriptor AS RT ON RaceDisp.Race = RT.DescriptorId
	 
GO
/****** Object:  View [BI].[eq24.StaffEducationOrganizationAssignmentAssociation]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BI].[eq24.StaffEducationOrganizationAssignmentAssociation]
AS


SELECT StaffUSI
      ,seoaa.EducationOrganizationId AS SchoolID
	  ,eo.NameOfInstitution AS School
	  ,sch.LocalEducationAgencyId
	  ,eo2.NameOfInstitution AS District
	  ,sct.ShortDescription AS StaffClassificationType
	  ,d.CodeValue AS StaffClassificationCode
	  ,d.ShortDescription AS StaffClassificationShortDescription
	  ,d.Description AS StaffClassificationDescription
      ,PositionTitle
	  ,BeginDate
      ,EndDate
     
  FROM edfi.StaffEducationOrganizationAssignmentAssociation AS seoaa
  LEFT JOIN edfi.Descriptor                                 AS d     ON seoaa.StaffClassificationDescriptorId = d.DescriptorId
  LEFT JOIN edfi.EducationOrganization                      AS eo    ON seoaa.EducationOrganizationId = eo.EducationOrganizationId
  LEFT JOIN edfi.School                                     AS sch   ON sch.SchoolId = seoaa.EducationOrganizationId
  LEFT JOIN edfi.EducationOrganization                      AS eo2   ON sch.LocalEducationAgencyId = eo2.EducationOrganizationId
  LEFT JOIN edfi.StaffClassificationDescriptor              AS scd   ON seoaa.StaffClassificationDescriptorId = scd.StaffClassificationDescriptorId
  LEFT JOIN edfi.Descriptor                    AS sct   ON scd.StaffClassificationDescriptorId = sct.DescriptorId
  WHERE  (year(BeginDate) = (SELECT * FROM [bi].[eq24.YearStart]())-10
	   OR year(BeginDate) = (SELECT * FROM [bi].[eq24.YearStart]()) + 1)
GO
/****** Object:  View [BI].[eq24.StaffSectionAssociation]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [BI].[eq24.StaffSectionAssociation]
AS
SELECT [StaffUSI]
      ,''[ClassroomIdentificationCode]
      ,ssa.[SchoolId]
      ,''[ClassPeriodName]
      ,[LocalCourseCode]
      ,[SchoolYear]
	  ,'' AS Term
      ,''[UniqueSectionCode]
	  ,d2.ShortDescription AS ClassroomPosition
      ,[BeginDate]
      ,[EndDate]
	  ,s.LocalEducationAgencyId
  FROM [edfi].[StaffSectionAssociation] ssa
--  LEFT JOIN [edfi].[Descriptor] d ON ssa.TermDescriptorId = d.DescriptorId
  LEFT JOIN [edfi].[Descriptor] d2 ON ssa.ClassroomPositionDescriptorId = d2.DescriptorId
  LEFT JOIN [edfi].[School] s ON ssa.SchoolId = s.SchoolId
GO
/****** Object:  View [BI].[eq24.Student]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [BI].[eq24.Student]
AS
    SELECT 
           Student.[StudentUSI], 
           Student.[PersonalTitlePrefix], 
           Student.[FirstName], 
           Student.[MiddleName], 
           Student.[LastSurname], 
           Student.[GenerationCodeSuffix], 
           Student.[MaidenName], 
           BirthSexDescriptorId [SexTypeId], 
           Student.[BirthDate], 
           Student.[BirthCity], 
           BirthStateAbbreviationDescriptorId [BirthStateAbbreviationTypeId], 
           Student.[DateEnteredUS], 
           Student.[MultipleBirthStatus], 
           '' [ProfileThumbnail], 
           COALESCE(CASE WHEN schoolEdOrg.StudentUSI IS NOT NULL
                        THEN schoolEdOrg.HispanicLatinoEthnicity
                        ELSE districtEdOrg.HispanicLatinoEthnicity
                    END, CAST(0 AS BIT)) AS [HispanicLatinoEthnicity], 
           '' [OldEthnicityTypeId], 
           '' [EconomicDisadvantaged], 
           '' [SchoolFoodServicesEligibilityDescriptorId], 
           COALESCE(CASE WHEN schoolEdOrg.StudentUSI IS NOT NULL
                        THEN LimitedEnglishDescriptorSchool.CodeValue
                        ELSE LimitedEnglishDescriptorDist.CodeValue
                    END, 'Not applicable') AS LimitedEnglishProficiency, 
           '' [DisplacementStatus], 
           '' [LoginId], 
           [BirthInternationalProvince], 
           CitizenshipStatusDescriptorId [CitizenshipStatusTypeId], 
           Student.[StudentUniqueId], 
           Student.[Id], 
           ( SELECT 
                    MAX(MaxLastModifiedDate)
             FROM
                  (VALUES(Student.LastModifiedDate), (schoolEdOrg.LastModifiedDate), (districtEdOrg.LastModifiedDate)) AS VALUE(MaxLastModifiedDate)
           ) AS LastModifiedDate, 
           Student.[CreateDate], 
           COALESCE(CASE
                    WHEN schoolEdOrg.StudentUSI IS NOT NULL
                    THEN SexTypeSchool.CodeValue
                    ELSE SexTypeDist.CodeValue
                END, '') AS SexType, 
           (CASE WHEN RT.ShortDescription IS NULL
                THEN(CASE WHEN RaceDisp.Race IS NULL
                         THEN 'Unknown'
                         ELSE 'Multiracial'
                     END)
                ELSE RT.[ShortDescription]
            END) AS FederalRace
    FROM 
         edfi.Student
    INNER JOIN
        edfi.StudentSchoolAssociation ON
            Student.StudentUSI = StudentSchoolAssociation.StudentUSI
    INNER JOIN
        edfi.Descriptor ON
            StudentSchoolAssociation.EntryGradeLevelDescriptorId = Descriptor.DescriptorId
    INNER JOIN
        edfi.School ON
            StudentSchoolAssociation.SchoolId = School.SchoolId
    LEFT OUTER JOIN
        edfi.StudentEducationOrganizationAssociation AS schoolEdOrg ON
            Student.StudentUSI = schoolEdOrg.StudentUSI
            AND
            StudentSchoolAssociation.SchoolId = schoolEdOrg.EducationOrganizationId
    LEFT OUTER JOIN
        edfi.Descriptor AS LimitedEnglishDescriptorSchool ON
            schoolEdOrg.LimitedEnglishProficiencyDescriptorId = LimitedEnglishDescriptorSchool.DescriptorId
    LEFT OUTER JOIN
        edfi.Descriptor AS SexTypeSchool ON
            schoolEdOrg.SexDescriptorId = SexTypeSchool.DescriptorId
    LEFT OUTER JOIN
        edfi.StudentEducationOrganizationAssociation AS districtEdOrg ON
            Student.StudentUSI = districtEdOrg.StudentUSI
            AND
            School.LocalEducationAgencyId = districtEdOrg.EducationOrganizationId
    LEFT OUTER JOIN
        edfi.Descriptor AS LimitedEnglishDescriptorDist ON
            districtEdOrg.LimitedEnglishProficiencyDescriptorId = LimitedEnglishDescriptorDist.DescriptorId
    LEFT OUTER JOIN
        edfi.Descriptor AS SexTypeDist ON
            districtEdOrg.SexDescriptorId = SexTypeDist.DescriptorId
    LEFT JOIN
        ( SELECT DISTINCT 
                 t1.StudentUSI, 
                 STUFF(
                        ( SELECT TOP 1 
                                 CAST(t2.RaceDescriptorId AS VARCHAR(100))
                          FROM 
                               edfi.StudentEducationOrganizationAssociationRace t2
                          WHERE
                                  t2.StudentUSI = t1.StudentUSI FOR
                          XML PATH('')
                        ), 1, 0, '') AS Race
          FROM 
               edfi.StudentEducationOrganizationAssociationRace t1
        ) AS RaceDisp ON
            Student.[StudentUSI] = RaceDisp.StudentUSI
    LEFT JOIN
        edfi.Descriptor AS RT ON
            RaceDisp.Race = RT.DescriptorId;
GO
/****** Object:  View [BI].[eq24.StudentAssessmentPerformanceLevel]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [BI].[eq24.StudentAssessmentPerformanceLevel]
AS
    SELECT 
           REPLACE(sa.[AssessmentIdentifier], '_AL_', '_') AS AssessmentIdentifier, 
           REPLACE(sa.[StudentAssessmentIdentifier], '_AL_', '_') AS StudentAssessmentIdentifier, 
           sa.[StudentUSI], 
           [AdministrationDate], 
           d.CodeValue AS GradeLevel, 
           d2.CodeValue AS AcademicSubject, 
           sasr.AssessmentReportingMethodDescriptorId AssessmentReportingMethodTypeId, 
           a.AssessmentTitle, 
           sasr.Result, 
           sasr.Namespace, 
           '' Version
    FROM 
         [edfi].[StudentAssessment] sa
    LEFT JOIN
        [edfi].[StudentAssessmentScoreResult] sasr ON
            sasr.StudentUSI = sa.StudentUSI
            AND
            sasr.StudentAssessmentIdentifier = sa.StudentAssessmentIdentifier
            AND
            sasr.AssessmentIdentifier = sa.AssessmentIdentifier
            AND
            sasr.Namespace = sa.Namespace
    LEFT JOIN
        [edfi].[Assessment] a ON
            sa.AssessmentIdentifier = a.AssessmentIdentifier
            AND
            sa.Namespace = a.Namespace
    LEFT JOIN
        [edfi].[AssessmentAcademicSubject] aas ON
            sa.AssessmentIdentifier = aas.AssessmentIdentifier
            AND
            sa.Namespace = aas.Namespace
    LEFT JOIN
        [edfi].[Descriptor] d ON
            sa.WhenAssessedGradeLevelDescriptorId = d.DescriptorId
    LEFT JOIN
        [edfi].[Descriptor] d2 ON
            aas.AcademicSubjectDescriptorId = d2.DescriptorId
    LEFT JOIN
        edfi.Descriptor rpt ON
            AssessmentReportingMethodDescriptorId = rpt.DescriptorId
    WHERE
          AssessmentReportingMethodDescriptorId = 213 --rpt.CodeValue = 'Achievement/proficiency level'
            -- AND sa.StudentAssessmentIdentifier like '%_Mathematics_%'
            AND d2.CodeValue IN('Mathematics')
    AND AssessmentTitle NOT IN('Curriculum Associates i-Ready Math Diagnostic', 'ACT', 'PERT', 'PER', 'PSANM', 'SAT 2016', 'PSAT 89');
GO
/****** Object:  View [BI].[eq24.StudentAssessmentScoreResult]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [BI].[eq24.StudentAssessmentScoreResult]
AS
    SELECT 
           REPLACE(sa.[AssessmentIdentifier], '_SS_', '_') AS AssessmentIdentifier, 
           REPLACE(sa.[StudentAssessmentIdentifier], '_SS_', '_') AS StudentAssessmentIdentifier, 
           sa.[StudentUSI], 
           [AdministrationDate], 
           d.CodeValue AS GradeLevel, 
           d2.CodeValue AS AcademicSubject, 
           sasr.AssessmentReportingMethodDescriptorId AS AssessmentReportingMethodTypeId, 
           a.AssessmentTitle, 
           sasr.Result, 
           '' Version, 
           '' [Namespace]
    FROM 
         [edfi].[StudentAssessment] sa
    LEFT JOIN
        [edfi].[StudentAssessmentScoreResult] sasr ON
            sasr.StudentUSI = sa.StudentUSI
            AND
            sasr.StudentAssessmentIdentifier = sa.StudentAssessmentIdentifier
            AND
            sasr.AssessmentIdentifier = sa.AssessmentIdentifier
            AND
            sasr.Namespace = sa.Namespace
    LEFT JOIN
        [edfi].[Assessment] a ON
            sa.AssessmentIdentifier = a.AssessmentIdentifier
            AND
            sa.Namespace = a.Namespace
    LEFT JOIN
        [edfi].[AssessmentAcademicSubject] aas ON
            sa.AssessmentIdentifier = aas.AssessmentIdentifier
            AND
            sa.Namespace = aas.Namespace
    LEFT JOIN
        [edfi].[Descriptor] d ON
            sa.WhenAssessedGradeLevelDescriptorId = d.DescriptorId
    LEFT JOIN
        [edfi].[Descriptor] d2 ON
            aas.AcademicSubjectDescriptorId = d2.DescriptorId
    LEFT JOIN
        edfi.Descriptor rpt ON
            AssessmentReportingMethodDescriptorId = rpt.DescriptorId
    WHERE
            AssessmentReportingMethodDescriptorId = 213 --            rpt.CodeValue = 'Scale score'
            /*sa.StudentAssessmentIdentifier like '%_Mathematics_%'*/

            AND d2.CodeValue IN('Mathematics')
    AND AssessmentTitle NOT IN('Curriculum Associates i-Ready Math Diagnostic', 'ACT', 'PERT', 'PER', 'PSANM', 'SAT 2016', 'PSAT 89');
GO
/****** Object:  View [BI].[eq24.StudentAssessmentStudentObjectiveAssessmentPointsPossible]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [BI].[eq24.StudentAssessmentStudentObjectiveAssessmentPointsPossible]
AS
    SELECT DISTINCT 
           REPLACE([AssessmentIdentifier], '_SS_', '_') AS AssessmentIdentifier, 
           armt.Description AS ReportingMethod, 
           /*SUBSTRING([IdentificationCode], 1, 2)*/IdentificationCode AS IdentificationCode, 
           sasoasr.[Namespace], 
           REPLACE([StudentAssessmentIdentifier], '_SS_', '_') AS StudentAssessmentIdentifier, 
           sasoasr.[StudentUSI], 
           [Result], 
           rdt.Description AS ResultDatatype
    FROM 
         [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult] sasoasr
    LEFT JOIN
        [edfi].[Descriptor] armt ON
            sasoasr.AssessmentReportingMethodDescriptorId = armt.DescriptorId
    LEFT JOIN
        [edfi].[Descriptor] rdt ON
            sasoasr.ResultDatatypeTypeDescriptorId = rdt.DescriptorId;

/*WHERE IdentificationCode like '%_PP'
 AND  StudentAssessmentIdentifier like '%_Mathematics_%'*/

GO
/****** Object:  View [BI].[eq24.StudentAssessmentStudentObjectiveAssessmentScoreResult]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [BI].[eq24.StudentAssessmentStudentObjectiveAssessmentScoreResult]

AS

SELECT REPLACE([AssessmentIdentifier],'_SS_','_') AS AssessmentIdentifier
      ,armt.Description AS ReportingMethod
      ,[IdentificationCode] /*SUBSTRING([IdentificationCode],1,2)*/ AS IdentificationCode
      ,sasoasr.[Namespace]
      ,REPLACE([StudentAssessmentIdentifier],'_SS_','_') AS StudentAssessmentIdentifier
      ,sasoasr.[StudentUSI]
      ,[Result]
      ,rdt.Description AS ResultDatatype
FROM [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult] sasoasr
 LEFT JOIN [edfi].Descriptor armt ON sasoasr.AssessmentReportingMethodDescriptorId = armt.DescriptorId
 LEFT JOIN [edfi].Descriptor rdt ON sasoasr.ResultDatatypeTypeDescriptorId = rdt.DescriptorId
 /*WHERE IdentificationCode like '%_PE' 
 AND StudentAssessmentIdentifier like '%_Mathematics_%'*/

GO
/****** Object:  View [BI].[eq24.StudentProgramAssociation]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BI].[eq24.StudentProgramAssociation] 

AS


SELECT [StudentUSI]
      ,[ProgramName]
      ,MAX([BeginDate]) AS BeginDate
      ,null [EndDate]

FROM [edfi].[StudentProgramAssociation]

/*WHERE  StudentUSI IN (SELECT DISTINCT [StudentUSI]      
                     FROM [bi].[eq24.StudentSchoolAssociation]
                     WHERE LocalEducationAgencyId = 38)
 */

GROUP BY [StudentUSI]
      ,[ProgramName]
     -- ,[EndDate]
GO
/****** Object:  View [BI].[eq24.StudentSchoolAssociation]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [BI].[eq24.StudentSchoolAssociation] 

AS

SELECT ssa.[StudentUSI],
	   ssa.[SchoolId],
	   eo.NameOfInstitution,
	   ssa.[SchoolYear],
	   ssa.[EntryDate],
	   ssa.[EntryGradeLevelDescriptorId],
	   d.ShortDescription AS [Grade Level],
	   d.CodeValue AS GradeLevelNum,
	   ssa.[ExitWithdrawDate],
	   D2.CodeValue AS ExitWithdrawCode,
       D2.ShortDescription as ExitWithdrawDescription,
	   ssa.ClassOfSchoolYear,
	   ssa.GraduationSchoolYear,
	   s.LocalEducationAgencyId
FROM [edfi].[StudentSchoolAssociation] ssa
LEFT JOIN edfi.School s ON ssa.SchoolId = s.SchoolId 
LEFT JOIN edfi.Descriptor d ON ssa.EntryGradeLevelDescriptorId = d.DescriptorId
LEFT JOIN edfi.EducationOrganization eo ON ssa.SchoolId = eo.EducationOrganizationId
LEFT JOIN [edfi].[Descriptor] D2 on ssa.ExitWithdrawTypeDescriptorId = D2.DescriptorId

	
GO
/****** Object:  View [BI].[eq24.StudentSectionAssociation]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [BI].[eq24.StudentSectionAssociation] 

AS

 SELECT ssa.[StudentUSI]
      ,ssa.[SchoolId]
      ,''[ClassPeriodName]
      ,''[ClassroomIdentificationCode]
      ,[LocalCourseCode]
      ,''[UniqueSectionCode]
      ,''[SequenceOfCourse]
      ,[SchoolYear]
      ,'' AS Term
      ,[BeginDate]
      ,[EndDate]
      ,[HomeroomIndicator]
	  ,s.LocalEducationAgencyId
  FROM [edfi].[StudentSectionAssociation] ssa
--  LEFT JOIN [edfi].[Descriptor] d ON ssa.TermDescriptorId = d.DescriptorId
  LEFT JOIN [edfi].[School] s ON ssa.SchoolId = s.SchoolId
 -- WHERE  SUBSTRING(LocalCourseCode,11,2) in ( '12')
GO
/****** Object:  View [BI].[uniform.StaffSectionAssociation]    Script Date: 1/27/2021 4:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [BI].[uniform.StaffSectionAssociation]
AS
SELECT [StaffUSI]
      ,''[ClassroomIdentificationCode]
      ,ssa.[SchoolId]
      ,''[ClassPeriodName]
      ,[LocalCourseCode]
      ,[SchoolYear]
	  ,'' AS Term
      ,''[UniqueSectionCode]
	  ,d2.ShortDescription AS ClassroomPosition
      ,[BeginDate]
      ,[EndDate]
	  ,s.LocalEducationAgencyId
  FROM [edfi].[StaffSectionAssociation] ssa
--  LEFT JOIN [edfi].[Descriptor] d ON ssa.TermDescriptorId = d.DescriptorId
  LEFT JOIN [edfi].[Descriptor] d2 ON ssa.ClassroomPositionDescriptorId = d2.DescriptorId
  LEFT JOIN [edfi].[School] s ON ssa.SchoolId = s.SchoolId
GO

