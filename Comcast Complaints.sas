FILENAME REFFILE '/home/u43036022/Comcast Telecom Complaints data.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.Comcast_Complaints;
	GETNAMES=YES;
RUN;

PROC PRINT DATA=WORK.Comcast_Complaints; RUN;





ods graphics / reset width=7in height=7in imagemap;

proc sort data=WORK.COMCAST_COMPLAINTS out=_SeriesPlotTaskData;
	by Date_month_year;
run;

proc sgplot data=_SeriesPlotTaskData;
	series x=Date_month_year y=Complaint_Type / lineattrs=(thickness=3 
		color=CX003399);
	xaxis GRID;
	yaxis grid;
run;

ods graphics / reset;

proc datasets library=WORK noprint;
	delete _SeriesPlotTaskData;
	run;




proc freq data=WORK.COMCAST_COMPLAINTS order=freq;
	tables Complaint_Type / plots=(freqplot cumfreqplot);
run;



Data New_Variable;
 set WORK.Comcast_Complaints;
 select (Status);
 when ('Open') New_Status = 'Open';
 when ('Pending') New_Status = 'Open';
 when ('Closed') New_Status = 'Closed';
 when ('Solved') New_Status = 'Closed';
 otherwise;
 END;






ods graphics / reset width=10in height=10in imagemap;

proc sgplot data=WORK.COMCAST_COMPLAINTS;
	vbar State / group=Complaint_Type groupdisplay=stack datalabel;
	yaxis grid;
run;

ods graphics / reset;






PROC SQL;  
SELECT 
DISTINCT NEW_VARIABLE.State, COUNT(NEW_VARIABLE.New_Status)/51700*100
AS Percentage FORMAT = PERCENT8.2
FROM WORK.NEW_VARIABLE NEW_VARIABLE 
WHERE 
   ( NEW_VARIABLE.New_Status = 'Open' ) 
GROUP BY NEW_VARIABLE.State 
ORDER BY Percentage DESC; 
QUIT;





PROC SQL; 
SELECT COUNT(COMCAST_COMPLAINTS.Complaint_Type) 
AS 'Resolved complaints till date'n, COUNT(COMCAST_COMPLAINTS.Status) /222400*100
AS Percentage FORMAT=PERCENT8.2
FROM WORK.COMCAST_COMPLAINTS COMCAST_COMPLAINTS 
WHERE 
   ( COMCAST_COMPLAINTS.Status = 'Solved ' ) 
ORDER BY Percentage DESC; 
QUIT;