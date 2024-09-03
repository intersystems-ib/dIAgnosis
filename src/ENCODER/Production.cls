Class ENCODER.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="ENCODER.Production" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>10</ActorPoolSize>
  <Item Name="ENCODER.BS.CodeImportService" Category="" ClassName="ENCODER.BS.CodeImportService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/iris-shared/in/</Setting>
    <Setting Target="Host" Name="CodeType">CIE10</Setting>
    <Setting Target="Adapter" Name="Charset">utf-8</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.csv</Setting>
  </Item>
  <Item Name="ENCODER.BP.CodeImportProcess" Category="" ClassName="ENCODER.BP.CodeImportProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="HL7_File_In" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5</Setting>
    <Setting Target="Adapter" Name="FilePath">/iris-shared/HL7In/</Setting>
    <Setting Target="Host" Name="TargetConfigNames">ENCODER.BP.HL7ToCodeBPL</Setting>
    <Setting Target="Adapter" Name="Charset">utf-8</Setting>
    <Setting Target="Host" Name="DefCharEncoding">utf-8</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hl7</Setting>
  </Item>
  <Item Name="ENCODER.BP.HL7ToCodeBPL" Category="" ClassName="ENCODER.BP.HL7ToCodeBPL" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="ENCODER.BP.CreateHL7Message" Category="" ClassName="ENCODER.BP.CreateHL7Message" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="HL7_File_Out" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/iris-shared/HL7Out/</Setting>
    <Setting Target="Host" Name="DefCharEncoding">utf-8</Setting>
  </Item>
  <Item Name="ENCODER.BP.AnalyzeTextProcess" Category="" ClassName="ENCODER.BP.AnalyzeTextProcess" PoolSize="10" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="ENCODER.BS.AnalyzeTextService" Category="" ClassName="ENCODER.BS.AnalyzeTextService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
