Class ENCODER.BS.AnalyzeTextService Extends Ens.BusinessService
{

Method OnProcessInput(pInput As ENCODER.Message.AnalysisRequest, Output pOutput As %RegisteredObject) As %Status
{
    set tSC = ..SendRequestSync("ENCODER.BP.AnalyzeTextProcess", pInput, .pResponse)
    $$$TRACE(pResponse.Result)
    return $$$OK
}

}
