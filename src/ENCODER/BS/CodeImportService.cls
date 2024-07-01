Class ENCODER.BS.CodeImportService Extends Ens.BusinessService
{

Property CodeType As %String;

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Parameter SETTINGS = "CodeType";

Method OnProcessInput(pInput As %Stream.FileCharacter, Output pOutput As %RegisteredObject) As %Status
{
    set pRequest = ##class(ENCODER.Message.GenericRequest).%New()
    set pRequest.FilePath = pInput.Filename
    set pRequest.CodeType = ..CodeType
    set tSC = ..SendRequestSync("ENCODER.BP.CodeImportProcess", pRequest, .pResponse)
    $$$TRACE(pResponse.Result)
    return $$$OK
}

}
