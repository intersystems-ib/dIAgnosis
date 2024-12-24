Class ENCODER.WS.Service Extends %CSP.REST
{

Parameter HandleCorsRequest = 0;

Parameter CHARSET = "utf-8";

Parameter CONVERTINPUTSTREAM = 1;

XData UrlMap [ XMLNamespace = "https://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/getCodeOptions/:idRequest" Method="GET" Call="GetCodeOptions" />
    <Route Url="/getCodeRequests" Method="GET" Call="GetCodeRequests" />
    <Route Url="/saveCodification" Method="POST" Call="SaveCodification" />
    <Route Url="/sendNotification" Method="POST" Call="SendNotification" />
    <Route Url="/analyzeText" Method="POST" Call="AnalyzeText" />
    <Route Url="/saveRawText" Method="POST" Call="SaveRawText" />
    <Route Url="/getAnalyzedText/:idAnalysis" Method="GET" Call="GetAnalyzedText" />
    <Route Url="/getAnalysis" Method="GET" Call="GetAnalysis" />
    <Route Url="/getAnalysisDetails/:idAnalysis" Method="GET" Call="GetAnalysisDetails" />
    <Route Url="/saveCodeFile" Method="POST" Call="SaveCodeFile" />
    <Route Url="/getVectorizationInfo" Method="GET" Call="GetVectorizationInfo" />
</Routes>
}

ClassMethod OnHandleCorsRequest(url As %String) As %Status
{
	set url = %request.GetCgiEnv("HTTP_REFERER")
    set origin = $p(url,"/",1,3) // origin = "http(s)://origin.com:port"

    // here you can check specific origins
    // otherway, it will allow all origins (useful while developing only)

	do %response.SetHeader("Access-Control-Allow-Credentials","true")
	do %response.SetHeader("Access-Control-Allow-Methods","GET,POST,PUT,DELETE,OPTIONS")
	do %response.SetHeader("Access-Control-Allow-Origin",origin)
	do %response.SetHeader("Access-Control-Allow-Headers","Access-Control-Allow-Origin, Origin, X-Requested-With, Content-Type, Accept, Authorization, Cache-Control")
	quit $$$OK
}

ClassMethod GetCodeOptions(idRequest As %String) As %Status
{
	set ret = $$$OK
    try {
        set sql = 
            "SELECT TOP 25 * FROM (SELECT C.CodeId, C.Description, VECTOR_DOT_PRODUCT(C.VectorDescription, R.VectorDescription) AS Similarity FROM ENCODER_Object.Codes C, ENCODER_Object.CodeRequests R WHERE R.ID = ?) WHERE Similarity > 0.5 ORDER BY Similarity DESC"

		set statement = ##class(%SQL.Statement).%New()
		$$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute(idRequest)

        set array = []
        while rs.%Next() {
            do array.%Push({
                    "CodeId": (rs.%Get("CodeId")),
                    "Description": (rs.%Get("Description")),
                    "Similarity": (rs.%Get("Similarity"))
                })
        }
        set %response.Status = ..#HTTP200OK
        write array.%ToJSON()

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod GetCodeRequests() As %Status
{
	set ret = $$$OK
    try {
        //set description = $get(%request.Data("description",1))

        set sql = 
            "SELECT %ID, MessageId, Description, Code->CodeId As CodeId, Code->Description As CodeDescription FROM ENCODER_Object.CodeRequests "_            
            "ORDER BY MessageId ASC"

		set statement = ##class(%SQL.Statement).%New()
		$$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute()

        set array = []
        while rs.%Next() {
            do array.%Push({
                    "Id": (rs.%Get("ID")),
                    "MessageId": (rs.%Get("MessageId")),
                    "Description": (rs.%Get("Description")),
                    "CodeId": (rs.%Get("CodeId")),
                    "CodeDescription": (rs.%Get("CodeDescription"))
                })
        }
        set %response.Status = ..#HTTP200OK
        write array.%ToJSON()

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod SaveCodification() As %Status
{
	set ret = $$$OK
    try {
        set dynamicBody = {}.%FromJSON(%request.Content)
        set sql = "UPDATE ENCODER_Object.CodeRequests SET Code = (SELECT ID FROM ENCODER_Object.Codes WHERE CodeId = ?) WHERE ID = ?"
        
        set statement = ##class(%SQL.Statement).%New()
		$$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.execute(dynamicBody.%Get("Code"), dynamicBody.%Get("CodeRequestId"))

        set %response.Status = ..#HTTP200OK

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod SendNotification() As %Status
{
	set ret = $$$OK
    try {
        set dynamicBody = {}.%FromJSON(%request.Content)
        set notificationRequest = ##class(ENCODER.Message.NotifyRequest).%New()
        set notificationRequest.CodeRequestId = dynamicBody.%Get("CodeRequestId")
        
        // Creation of BS instance
        set status = ##class(Ens.Director).CreateBusinessService("ENCODER.BS.CodeImportService", .instance)
        set tSC = instance.SendRequestSync("ENCODER.BP.CreateHL7Message", notificationRequest, .response)

        set %response.Status = ..#HTTP200OK

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod AnalyzeText() As %Status
{
	set ret = $$$OK
    try {
        set dynamicBody = {}.%FromJSON(%request.Content)
        set analysisRequest = ##class(ENCODER.Message.AnalysisRequest).%New()
        set analysisRequest.TextToAnalyze = dynamicBody.%Get("Text")
        set analysisRequest.AnalysisId = dynamicBody.%Get("ID")
        set analysisRequest.LanguageSelected = dynamicBody.%Get("Language")
        set analysisRequest.UseLLM = dynamicBody.%Get("UseLLM")
        
        // Creation of BS instance
        set status = ##class(Ens.Director).CreateBusinessService("ENCODER.BS.AnalyzeTextService", .instance)
        set tSC = instance.SendRequestSync("ENCODER.BP.AnalyzeTextProcess", analysisRequest, .response)
                
        set %response.Status = ..#HTTP200OK

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod SaveRawText() As %Status
{
	set ret = $$$OK
    try {
        set dynamicBody = {}.%FromJSON(%request.Content)
        set rawText = ##class(ENCODER.Object.RawTexts).%New()
        set rawText.RawText = dynamicBody.%Get("Text")
        set rawText.AnalysisDate = $ZDATETIME($H,3,1)
        set sc = rawText.%Save()
        
        write {"id": (rawText.%Id())}.%ToJSON()
        set %response.Status = ..#HTTP200OK

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod GetAnalyzedText(idAnalysis As %String) As %Status
{
	set ret = $$$OK
    try {
        set sql = 
            "SELECT CodeId, RawText, Description, max(Similarity) as Similarity FROM ENCODER_Object.TextMatches WHERE AnalysisId = ? GROUP BY CodeId ORDER BY Similarity DESC"

		set statement = ##class(%SQL.Statement).%New()
		$$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute(idAnalysis)

        set array = []
        while rs.%Next() {
            do array.%Push({
                    "CodeId": (rs.%Get("CodeId")),
                    "RawText": (rs.%Get("RawText")),
                    "Description": (rs.%Get("Description")),
                    "Similarity": (rs.%Get("Similarity"))
                })
        }
        write array.%ToJSON()
        set %response.Status = ..#HTTP200OK

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod GetAnalysis() As %Status
{
	set ret = $$$OK
    try {
        set sql = "SELECT R.ID, R.RawText, R.AnalysisDate FROM ENCODER_Object.RawTexts R JOIN ENCODER_Object.TextMatches T ON R.ID = T.AnalysisId GROUP BY R.ID"

		set statement = ##class(%SQL.Statement).%New()
		$$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute()

        set array = []
        while rs.%Next() {
            do array.%Push({
                    "Id": (rs.%Get("ID")),
                    "RawText": (rs.%Get("RawText")),
                    "AnalysisDate": (rs.%Get("AnalysisDate"))
                })
        }
        write array.%ToJSON()
        set %response.Status = ..#HTTP200OK

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod GetAnalysisDetails(idAnalysis As %String) As %Status
{
	set ret = $$$OK
    try {
        set sql = 
            "SELECT CodeId, RawText, Description, max(Similarity) as Similarity FROM ENCODER_Object.TextMatches WHERE AnalysisId = ? GROUP BY CodeId ORDER BY Similarity DESC"

		set statement = ##class(%SQL.Statement).%New()
		$$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute(idAnalysis)

        set array = []
        while rs.%Next() {
            do array.%Push({
                    "CodeId": (rs.%Get("CodeId")),
                    "RawText": (rs.%Get("RawText")),
                    "Description": (rs.%Get("Description")),
                    "Similarity": (rs.%Get("Similarity"))
                })
        }
        write array.%ToJSON()
        set %response.Status = ..#HTTP200OK

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod SaveCodeFile() As %Status
{
	set ret = $$$OK
    try {
        set dynamicBody = {}.%FromJSON(%request.Content)
        set dynamicStream = dynamicBody.%Get("File",,"stream<base64")
        
        set stream=##class(%Stream.FileBinary).%New()
        set sc=stream.LinkToFile("/iris-shared/in/codes.csv")
        set sc=stream.CopyFromAndSave(dynamicStream)
        HANG 5
        set %response.Status = ..#HTTP200OK

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

ClassMethod GetVectorizationInfo() As %Status
{
	set ret = $$$OK
    try {
        set sql = "SELECT Total.totalValue As TotalRecords, Vectorized.vectorizedValue As VectorizedRecords FROM "_
        "(SELECT count(ID) as totalValue FROM ENCODER_Object.Codes) Total, "_
        "(SELECT count(ID) as vectorizedValue FROM ENCODER_Object.Codes WHERE VectorDescription is not null) Vectorized"

		set statement = ##class(%SQL.Statement).%New()
		$$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute()

        set result = {}
        while rs.%Next() {
            set result = {
                    "TotalRecords": (rs.%Get("TotalRecords")),
                    "VectorizedRecords": (rs.%Get("VectorizedRecords"))
                }
        }
        write result.%ToJSON()
        set %response.Status = ..#HTTP200OK

    } catch ex {
        set %response.Status = ..#HTTP400BADREQUEST
        return ex.DisplayString()
    }
    quit ret
}

}
