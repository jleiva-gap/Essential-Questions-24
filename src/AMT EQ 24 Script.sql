USE [EdFi_Ods]


CREATE OR ALTER FUNCTION [BI].[eq24.YearStart]()
RETURNS @return TABLE ([YearStart] INT)
AS
BEGIN
  DECLARE @year char(20);
  IF month(getdate()) > 6  SET @year = year(getdate()) else SET @year = year(getdate()) - 1
  INSERT INTO @return SELECT @year;
  RETURN;
END;
GO
/****** Object:  View [BI].[amt.EducationOrganization]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.EducationOrganization]
AS
    SELECT 
           SchoolDim.SchoolKey AS EducationOrganizationId, 
           '' AS StateOrganizationId, 
           SchoolDim.SchoolName AS NameOfInstitution, 
           SchoolDim.LocalEducationAgencyKey AS LocalEducationAgencyId
    FROM 
         analytics.SchoolDim;
GO
/****** Object:  View [BI].[amt.Grade]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.Grade]
AS
    SELECT 
           COALESCE(BeginDate.Date, CAST(GradingPeriodDim.GradingPeriodBeginDateKey AS DATETIME)) AS BeginDate, 
           '' AS ClassPeriodName, 
           '' AS ClassroomIdentificationCode, 
           ews_StudentSectionGradeFact.NumericGradeEarned AS GradeEarned, 
           '' AS GradeType, 
           GradingPeriodDim.GradingPeriodDescription AS GradingPeriod, 
           COALESCE(BeginDate.Date, CAST(GradingPeriodDim.GradingPeriodBeginDateKey AS DATETIME)) AS GradingPeriodBeginDate, 
           StudentSectionDim.SectionKey AS SectionKey, 
           StudentSectionDim.LocalCourseCode AS LocalCourseCode, 
           SchoolDim.LocalEducationAgencyKey AS LocalEducationAgencyId, 
           SchoolDim.SchoolKey AS SchoolId, 
           StudentSectionDim.SchoolYear AS SchoolYear, 
           COALESCE(StudentSectionStartDate.Date, CAST(StudentSectionDim.StudentSectionStartDateKey AS DATETIME)) AS SectionBeginDate, 
           COALESCE(StudentSectionEndDate.Date, CAST(StudentSectionDim.StudentSectionEndDateKey AS DATETIME)) AS SectionEndDate, 
           '' AS SequenceOfCourse, 
           CONCAT(StudentSectionDim.StudentKey, '-', SchoolDim.SchoolKey) AS StudentUSI, 
           StudentSectionDim.Subject AS Subject, 
           '' AS Term, 
           '' AS UniqueSectionCode, 
           ews_StudentSectionGradeFact.GradingPeriodKey
    FROM 
         analytics.ews_StudentSectionGradeFact
    INNER JOIN
        analytics.StudentSectionDim ON
            analytics.ews_StudentSectionGradeFact.StudentSectionKey = analytics.StudentSectionDim.StudentSectionKey
            AND
            analytics.ews_StudentSectionGradeFact.SchoolKey = analytics.StudentSectionDim.SchoolKey
            AND
            analytics.ews_StudentSectionGradeFact.StudentKey = analytics.StudentSectionDim.StudentKey
            AND
            analytics.ews_StudentSectionGradeFact.SectionKey = analytics.StudentSectionDim.SectionKey
    INNER JOIN
        analytics.SchoolDim ON
            analytics.StudentSectionDim.SchoolKey = analytics.SchoolDim.SchoolKey
    LEFT JOIN
        analytics.DateDim StudentSectionStartDate ON
            StudentSectionDim.StudentSectionStartDateKey = StudentSectionStartDate.DateKey
    LEFT JOIN
        analytics.DateDim StudentSectionEndDate ON
            StudentSectionDim.StudentSectionEndDateKey = StudentSectionEndDate.DateKey
    LEFT JOIN
        analytics.GradingPeriodDim ON
            analytics.ews_StudentSectionGradeFact.GradingPeriodKey = analytics.GradingPeriodDim.GradingPeriodKey
    LEFT JOIN
        analytics.DateDim BeginDate ON
            GradingPeriodDim.GradingPeriodBeginDateKey = BeginDate.DateKey;

--WHERE    SUBSTRING(g.LocalCourseCode,11,2) in ( '12') --this filter selects math courses only for Florida districts.

GO
/****** Object:  View [BI].[amt.School]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.School]
AS
    SELECT 
           SchoolDim.LocalEducationAgencyKey AS LocalEducationAgencyId, 
           SchoolDim.SchoolName AS SchoolName, 
           SchoolDim.SchoolKey AS SchoolId, 
           SchoolDim.SchoolType AS SchoolType
    FROM 
         [analytics].[SchoolDim];
GO
/****** Object:  View [BI].[amt.Section]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.Section]
AS
    SELECT 
           s.[SchoolId], 
           CAST(s.SchoolId AS NVARCHAR) + '-' + s.LocalCourseCode + '-' + CAST(s.SchoolYear AS NVARCHAR) + '-' + s.SectionIdentifier + '-' + s.SessionName AS SectionKey, 
           '' [ClassPeriodName], 
           '' [ClassroomIdentificationCode], 
           [LocalCourseCode], 
           '' AS Term, 
           [SchoolYear], 
           '' [UniqueSectionCode], 
           [SequenceOfCourse], 
           EducationalEnvironmentDescriptorId AS [EducationalEnvironmentTypeId], 
           [AvailableCredits], 
           sch.LocalEducationAgencyId
    FROM 
         [edfi].[Section] s
         --LEFT JOIN [edfi].[Descriptor] d on s.TermDescriptorId = d.DescriptorId
    LEFT JOIN
        [edfi].[School] sch ON
            s.SchoolId = sch.SchoolId;
GO
/****** Object:  View [BI].[amt.Staff]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.Staff]
AS
    SELECT 
           s.StaffUSI, 
           s.StaffUniqueId, 
           s.PersonalTitlePrefix, 
           s.FirstName, 
           s.MiddleName, 
           s.LastSurname, 
           s.GenerationCodeSuffix, 
           s.MaidenName, 
           sem.ElectronicMailAddress, 
           sa.StreetNumberName, 
           sa.ApartmentRoomSuiteNumber, 
           sa.City, 
           sat.ShortDescription AS State, 
           sa.PostalCode, 
           st.ShortDescription AS SexType, 
           s.BirthDate, 
           (CASE WHEN RT.ShortDescription IS NULL
                THEN(CASE WHEN RaceDisp.Race IS NULL
                         THEN 'Unknown'
                         ELSE 'Multiracial'
                     END)
                ELSE RT.[ShortDescription]
            END) AS RaceType, 
           s.HispanicLatinoEthnicity, 
           s.OldEthnicityDescriptorId OldEthnicityTypeId, 
           d.ShortDescription AS HighestCompletedLevelOfEducation, 
           s.YearsOfPriorProfessionalExperience, 
           s.YearsOfPriorTeachingExperience, 
           s.HighlyQualifiedTeacher, 
           s.LoginId, 
           s.CitizenshipStatusDescriptorId CitizenshipStatusTypeId
    FROM 
         edfi.Staff AS s
    LEFT JOIN
        edfi.Descriptor AS st ON
            s.SexDescriptorId = st.DescriptorId
    LEFT JOIN
        edfi.Descriptor AS d ON
            s.HighestCompletedLevelOfEducationDescriptorId = d.DescriptorId
    LEFT JOIN
        edfi.StaffElectronicMail AS sem ON
            s.StaffUSI = sem.StaffUSI
    LEFT JOIN
        edfi.StaffAddress AS sa ON
            s.StaffUSI = sa.StaffUSI
    LEFT JOIN
        edfi.Descriptor AS sat ON
            sa.StateAbbreviationDescriptorId = sat.DescriptorId
    LEFT JOIN
        ( SELECT DISTINCT 
                 t1.StaffUSI, 
                 STUFF(
                        ( SELECT 
                                 CAST(t2.RaceDescriptorID AS VARCHAR(100))
                          FROM 
                               edfi.StaffRace t2
                          WHERE
                                  t2.StaffUSI = t1.StaffUSI FOR
                          XML PATH('')
                        ), 1, 0, '') AS Race
          FROM 
               edfi.StaffRace t1
        ) AS RaceDisp ON
            S.[StaffUSI] = RaceDisp.StaffUSI
    LEFT JOIN
        edfi.Descriptor AS RT ON
            RaceDisp.Race = RT.DescriptorId;
GO
/****** Object:  View [BI].[amt.StaffEducationOrganizationAssignmentAssociation]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.StaffEducationOrganizationAssignmentAssociation]
AS
    SELECT 
           StaffUSI, 
           seoaa.EducationOrganizationId AS SchoolID, 
           eo.NameOfInstitution AS School, 
           sch.LocalEducationAgencyId, 
           eo2.NameOfInstitution AS District, 
           sct.ShortDescription AS StaffClassificationType, 
           d.CodeValue AS StaffClassificationCode, 
           d.ShortDescription AS StaffClassificationShortDescription, 
           d.Description AS StaffClassificationDescription, 
           PositionTitle, 
           BeginDate, 
           EndDate
    FROM 
         edfi.StaffEducationOrganizationAssignmentAssociation AS seoaa
    LEFT JOIN
        edfi.Descriptor AS d ON
            seoaa.StaffClassificationDescriptorId = d.DescriptorId
    LEFT JOIN
        edfi.EducationOrganization AS eo ON
            seoaa.EducationOrganizationId = eo.EducationOrganizationId
    LEFT JOIN
        edfi.School AS sch ON
            sch.SchoolId = seoaa.EducationOrganizationId
    LEFT JOIN
        edfi.EducationOrganization AS eo2 ON
            sch.LocalEducationAgencyId = eo2.EducationOrganizationId
    LEFT JOIN
        edfi.StaffClassificationDescriptor AS scd ON
            seoaa.StaffClassificationDescriptorId = scd.StaffClassificationDescriptorId
    LEFT JOIN
        edfi.Descriptor AS sct ON
            scd.StaffClassificationDescriptorId = sct.DescriptorId
    WHERE(
         YEAR(BeginDate) =
                           ( SELECT 
                                    *
                             FROM 
                                  [bi].[eq24.YearStart]()
                           ) - 10
         OR
            YEAR(BeginDate) =
                              ( SELECT 
                                       *
                                FROM 
                                     [bi].[eq24.YearStart]()
                              ) + 1);
GO
/****** Object:  View [BI].[amt.StaffSectionAssociation]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.StaffSectionAssociation]
AS
    SELECT 
           [StaffUSI], 
           '' [ClassroomIdentificationCode], 
           ssa.[SchoolId], 
           CAST(s.SchoolId AS NVARCHAR) + '-' + ssa.LocalCourseCode + '-' + CAST(ssa.SchoolYear AS NVARCHAR) + '-' + ssa.SectionIdentifier + '-' + ssa.SessionName AS SectionKey, 
           '' [ClassPeriodName], 
           [LocalCourseCode], 
           [SchoolYear], 
           '' AS Term, 
           '' [UniqueSectionCode], 
           d2.ShortDescription AS ClassroomPosition, 
           [BeginDate], 
           [EndDate], 
           s.LocalEducationAgencyId
    FROM 
         [edfi].[StaffSectionAssociation] ssa
    LEFT JOIN
        [edfi].[Descriptor] d2 ON
            ssa.ClassroomPositionDescriptorId = d2.DescriptorId
    LEFT JOIN
        [edfi].[School] s ON
            ssa.SchoolId = s.SchoolId;
GO
/****** Object:  View [BI].[amt.Student]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.Student]
AS
    SELECT 
           NULL AS BirthDate, 
           '' AS CitizenshipStatusTypeId, 
           StudentSchoolDim.GradeLevel AS [Current Grade Level], 
           StudentSchoolDim.SchoolKey AS [Current School ID], 
           COALESCE(DemographicsEconomicDisadvantaged.IsEconomicDisadvantaged, 0) AS EconomicDisadvantaged, 
           COALESCE(Demographics.DemographicLabel, '') AS FederalRace, 
           StudentSchoolDim.StudentFirstName AS FirstName, 
           StudentSchoolDim.IsHispanic AS HispanicLatinoEthnicity, 
           StudentSchoolDim.StudentLastName AS LastSurname, 
           StudentSchoolDim.StudentMiddleName AS MiddleName, 
           '' AS OldEthnicityTypeId, 
           StudentSchoolDim.Sex AS SexType, 
           StudentSchoolDim.StudentSchoolKey AS StudentUniqueId, 
           StudentSchoolDim.StudentSchoolKey AS StudentUSI
    FROM 
         [analytics].[StudentSchoolDim]
    OUTER APPLY
         ( SELECT TOP 1 
                  DemographicLabel, 
                  StudentSchoolDemographicsBridge.StudentSchoolKey
           FROM 
                [analytics].[StudentSchoolDemographicsBridge]
           INNER JOIN
               [analytics].[DemographicDim] ON
                   DemographicDim.[DemographicKey] = StudentSchoolDemographicsBridge.[DemographicKey]
           WHERE
                   DemographicParentKey = 'Race'
                   AND
                   StudentSchoolDemographicsBridge.StudentSchoolKey = StudentSchoolDim.StudentSchoolKey
         ) AS Demographics
    OUTER APPLY
        ( SELECT TOP 1 
                 1 AS IsEconomicDisadvantaged
          FROM 
               [analytics].[StudentSchoolDemographicsBridge]
          INNER JOIN
              [analytics].[DemographicDim] ON
                  DemographicDim.[DemographicKey] = StudentSchoolDemographicsBridge.[DemographicKey]
          WHERE
                  DemographicDim.DemographicKey = 'StudentCharacteristic:Economic Disadvantaged'
                  AND
                  StudentSchoolDemographicsBridge.StudentSchoolKey = StudentSchoolDim.StudentSchoolKey
        ) AS DemographicsEconomicDisadvantaged;
GO
/****** Object:  View [BI].[amt.StudentAssessmentPerformanceLevel]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.StudentAssessmentPerformanceLevel]
AS
    SELECT DISTINCT 
           asmt_StudentAssessmentFact.AssessmentKey, 
           asmt_StudentAssessmentFact.AssessmentKey AS AssessmentIdentifier, 
           asmt_StudentAssessmentFact.StudentAssessmentKey, 
           asmt_StudentAssessmentFact.StudentAssessmentKey AS StudentAssessmentIdentifier, 
           asmt_StudentAssessmentFact.StudentSchoolKey AS StudentUSI, 
           COALESCE(DateDim.Date, CAST(asmt_StudentAssessmentFact.[AdministrationDate] AS DATETIME)) AS AdministrationDate, 
           asmt_AssessmentDim.AssessedGradeLevel AS GradeLevel, 
           asmt_AssessmentDim.AcademicSubject AS AcademicSubject, 
           asmt_StudentAssessmentFact.ReportingMethod AS AssessmentReportingMethodTypeId, 
           asmt_AssessmentDim.Title AS AssessmentTitle, 
           asmt_StudentAssessmentFact.StudentScore AS Result, 
           asmt_AssessmentDim.Namespace AS Namespace, 
           '' AS Version
    FROM 
         [analytics].[asmt_AssessmentDim]
    INNER JOIN
        [analytics].[asmt_StudentAssessmentFact] ON
            asmt_AssessmentDim.[AssessmentKey] = asmt_StudentAssessmentFact.[AssessmentKey]
    LEFT JOIN
        analytics.DateDim ON
            asmt_StudentAssessmentFact.AdministrationDate = DateDim.DateKey
    WHERE
          asmt_StudentAssessmentFact.ReportingMethod IN('Achievement/proficiency level', 'Raw score')--Raw score added for testing purposes.
    -- AND sa.StudentAssessmentIdentifier like '%_Mathematics_%'
    AND asmt_AssessmentDim.AcademicSubject IN('Mathematics')
         AND asmt_AssessmentDim.Title NOT IN('Curriculum Associates i-Ready Math Diagnostic', 'ACT', 'PERT', 'PER', 'PSANM', 'SAT 2016', 'PSAT 89');
GO
/****** Object:  View [BI].[amt.StudentAssessmentScoreResult]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.StudentAssessmentScoreResult]
AS
    SELECT DISTINCT 
           asmt_StudentAssessmentFact.AssessmentKey, 
           asmt_StudentAssessmentFact.AssessmentKey AS AssessmentIdentifier, 
           asmt_StudentAssessmentFact.StudentAssessmentKey, 
           asmt_StudentAssessmentFact.StudentAssessmentKey AS StudentAssessmentIdentifier, 
           asmt_StudentAssessmentFact.StudentSchoolKey AS StudentUSI, 
           COALESCE(DateDim.Date, CAST(asmt_StudentAssessmentFact.[AdministrationDate] AS DATETIME)) AS AdministrationDate, 
           asmt_AssessmentDim.AssessedGradeLevel AS GradeLevel, 
           asmt_AssessmentDim.AcademicSubject AS AcademicSubject, 
           asmt_StudentAssessmentFact.ReportingMethod AS AssessmentReportingMethodTypeId, 
           asmt_AssessmentDim.Title AS AssessmentTitle, 
           asmt_StudentAssessmentFact.StudentScore AS Result, 
           asmt_AssessmentDim.Namespace AS Namespace, 
           '' AS Version
    FROM 
         [analytics].[asmt_AssessmentDim]
    INNER JOIN
        [analytics].[asmt_StudentAssessmentFact] ON
            asmt_AssessmentDim.[AssessmentKey] = asmt_StudentAssessmentFact.[AssessmentKey]
        --INNER JOIN [analytics].[asmt_ObjectiveAssessmentDim] ON
        --    [asmt_AssessmentDim].[AssessmentKey]=[asmt_ObjectiveAssessmentDim].[AssessmentKey]
    LEFT JOIN
        analytics.DateDim ON
            asmt_StudentAssessmentFact.AdministrationDate = DateDim.DateKey
    WHERE
          asmt_StudentAssessmentFact.ReportingMethod IN('Scale score', 'Raw score')--Raw score added for testing purposes.
    -- AND sa.StudentAssessmentIdentifier like '%_Mathematics_%'
    AND asmt_AssessmentDim.AcademicSubject IN('Mathematics')
         AND asmt_AssessmentDim.Title NOT IN('Curriculum Associates i-Ready Math Diagnostic', 'ACT', 'PERT', 'PER', 'PSANM', 'SAT 2016', 'PSAT 89');
GO
/****** Object:  View [BI].[amt.StudentAssessmentStudentObjectiveAssessmentPointsPossible]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.StudentAssessmentStudentObjectiveAssessmentPointsPossible]
AS
    SELECT DISTINCT 
           asmt_StudentAssessmentObjectiveFact.AssessmentKey AS AssessmentIdentifier, 
           asmt_ObjectiveAssessmentDim.ObjectiveAssessmentKey AS ObjectiveAssessmentKey, 
           asmt_StudentAssessmentObjectiveFact.StudentObjectiveAssessmentKey, 
           asmt_StudentAssessmentObjectiveFact.[ReportingMethod] AS ReportingMethod, 
           asmt_ObjectiveAssessmentDim.IdentificationCode AS IdentificationCode, 
           asmt_StudentAssessmentObjectiveFact.Namespace AS Namespace, 
           asmt_StudentAssessmentObjectiveFact.[StudentObjectiveAssessmentKey] AS StudentAssessmentIdentifier, 
           asmt_StudentAssessmentObjectiveFact.[StudentSchoolKey] AS StudentUSI, 
           asmt_StudentAssessmentObjectiveFact.[StudentScore] AS Result, 
           asmt_StudentAssessmentObjectiveFact.[ResultDataType] AS ResultDatatype
    FROM 
         analytics.asmt_StudentAssessmentObjectiveFact
    INNER JOIN
        analytics.asmt_ObjectiveAssessmentDim ON
            asmt_ObjectiveAssessmentDim.[AssessmentKey] = asmt_StudentAssessmentObjectiveFact.[AssessmentKey]
            AND
            asmt_ObjectiveAssessmentDim.ObjectiveAssessmentKey = asmt_StudentAssessmentObjectiveFact.ObjectiveAssessmentKey;

/*WHERE IdentificationCode like '%_PP'
 AND  StudentAssessmentIdentifier like '%_Mathematics_%'*/

GO
/****** Object:  View [BI].[AMT.StudentAssessmentStudentObjectiveAssessmentScoreResult]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[AMT.StudentAssessmentStudentObjectiveAssessmentScoreResult]
AS
    SELECT DISTINCT 
           asmt_StudentAssessmentObjectiveFact.AssessmentKey AS AssessmentIdentifier, 
           asmt_ObjectiveAssessmentDim.ObjectiveAssessmentKey AS ObjectiveAssessmentKey, 
           asmt_StudentAssessmentObjectiveFact.StudentObjectiveAssessmentKey, 
           asmt_StudentAssessmentObjectiveFact.[ReportingMethod] AS ReportingMethod, 
           asmt_ObjectiveAssessmentDim.IdentificationCode AS IdentificationCode, 
           asmt_StudentAssessmentObjectiveFact.Namespace AS Namespace, 
           asmt_StudentAssessmentObjectiveFact.[StudentObjectiveAssessmentKey] AS StudentAssessmentIdentifier, 
           asmt_StudentAssessmentObjectiveFact.[StudentSchoolKey] AS StudentUSI, 
           asmt_StudentAssessmentObjectiveFact.[StudentScore] AS Result, 
           asmt_StudentAssessmentObjectiveFact.[ResultDataType] AS ResultDatatype
    FROM 
         analytics.asmt_StudentAssessmentObjectiveFact
    INNER JOIN
        analytics.asmt_ObjectiveAssessmentDim ON
            asmt_ObjectiveAssessmentDim.[AssessmentKey] = asmt_StudentAssessmentObjectiveFact.[AssessmentKey]
            AND
            asmt_ObjectiveAssessmentDim.ObjectiveAssessmentKey = asmt_StudentAssessmentObjectiveFact.ObjectiveAssessmentKey;

/*WHERE IdentificationCode like '%_PE' 
 AND StudentAssessmentIdentifier like '%_Mathematics_%'*/

GO
/****** Object:  View [BI].[amt.StudentProgramAssociation]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.StudentProgramAssociation]
AS
    SELECT 
           CONCAT(student.StudentUniqueId, '-', SchoolId) AS [StudentUSI], 
           [ProgramName], 
           MAX([BeginDate]) AS BeginDate, 
           NULL [EndDate]
    FROM 
         [edfi].[StudentProgramAssociation]
    INNER JOIN
        edfi.Student ON
            StudentProgramAssociation.StudentUSI = Student.StudentUSI
    INNER JOIN
        edfi.StudentSchoolAssociation ON
            Student.StudentUSI = StudentSchoolAssociation.StudentUSI

/*WHERE  StudentUSI IN (SELECT DISTINCT [StudentUSI]      
                     FROM [bi].[eq24.StudentSchoolAssociation]
                     WHERE LocalEducationAgencyId = 38)
 */

    GROUP BY 
             CONCAT(student.StudentUniqueId, '-', SchoolId), 
             [ProgramName];
-- ,[EndDate]
GO
/****** Object:  View [BI].[amt.StudentSchoolAssociation]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.StudentSchoolAssociation]
AS
    SELECT 
           StudentSchoolDim.[StudentSchoolKey] AS StudentUSI, 
           StudentSchoolDim.[SchoolKey] AS SchoolId, 
           SchoolDim.[SchoolName] AS NameOfInstitution, 
           StudentSchoolDim.[SchoolYear] AS SchoolYear, 
           StudentSchoolDim.[EnrollmentDateKey] AS EntryDate, 
           '' AS EntryGradeLevelDescriptorId, 
           StudentSchoolDim.[GradeLevel] AS [Grade Level], 
           StudentSchoolDim.[GradeLevel] AS GradeLevelNum, 
           NULL AS ExitWithdrawDate, 
           NULL AS ExitWithdrawCode, 
           NULL AS ExitWithdrawDescription, 
           0 AS ClassOfSchoolYear, 
           '' AS GraduationSchoolYear, 
           SchoolDim.LocalEducationAgencyKey AS LocalEducationAgencyId
    FROM 
         [analytics].[StudentSchoolDim]
    INNER JOIN
        [analytics].[SchoolDim] ON
            StudentSchoolDim.[SchoolKey] = SchoolDim.[SchoolKey];
GO
/****** Object:  View [BI].[amt.StudentSectionAssociation]    Script Date: 2/18/2021 2:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [BI].[amt.StudentSectionAssociation]
AS
    SELECT 
           CONCAT(StudentSectionDim.[StudentKey], '-', StudentSectionDim.[SchoolKey]) AS StudentUSI, 
           StudentSectionDim.StudentSectionKey, 
           StudentSectionDim.SchoolKey AS SchoolId, 
           StudentSectionDim.SectionKey, 
           '' AS ClassPeriodName, 
           '' AS ClassroomIdentificationCode, 
           StudentSectionDim.LocalCourseCode AS LocalCourseCode, 
           '' AS UniqueSectionCode, 
           '' AS SequenceOfCourse, 
           StudentSectionDim.SchoolYear AS SchoolYear, 
           '' AS Term, 
           CAST(StudentSectionDim.StudentSectionStartDateKey AS DATE) AS BeginDate, 
           CAST(StudentSectionDim.StudentSectionEndDateKey AS DATE) AS EndDate, 
           0 AS HomeroomIndicator, 
           SchoolDim.LocalEducationAgencyKey AS LocalEducationAgencyId
    FROM 
         analytics.StudentSectionDim
    INNER JOIN
        analytics.SchoolDim ON
            StudentSectionDim.SchoolKey = SchoolDim.SchoolKey;
-- WHERE  SUBSTRING(LocalCourseCode,11,2) in ( '12')
GO