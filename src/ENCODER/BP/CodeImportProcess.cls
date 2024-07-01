Class ENCODER.BP.CodeImportProcess Extends Ens.BusinessProcess
{

Method OnRequest(pInput As ENCODER.Message.GenericRequest, Output pOutput As ENCODER.Message.GenericResponse) As %Status
{
        
        set result = ..ParseCIE10(pInput.FilePath, pInput.CodeType)
        set pOutput = ##class(ENCODER.Message.GenericResponse).%New()
        set pOutput.Result = result
        return $$$OK
}

Method ParseCIE10(filePath As %String, codeType As %String) As %String [ Language = python ]
{
    import csv
    import iris
    import pandas as pd
    import sentence_transformers

    try :
        stmt = iris.sql.prepare("TRUNCATE TABLE ENCODER_Object.Codes")
        rs = stmt.execute()

        with open(filePath, "r",  encoding="utf-8") as csvfile:
            reader = csv.reader(csvfile, delimiter = ";")
            rows = 0
            for row in reader:                
                stmt = iris.sql.prepare("INSERT INTO ENCODER_Object.Codes (CodeId, Description, CodeType) VALUES (?,?,?)")
                rs = stmt.execute(str(row[0]), row[1],codeType)
                rows = rows + 1                
        bulk = 100
        loops = rows//bulk
        for x in range(0,loops + 1):
            startID = (bulk * x) + 1
            endID = (bulk * x) + bulk
            st = iris.sql.prepare("SELECT CodeId, Description FROM ENCODER_Object.Codes WHERE ID between ? AND ? ")
            resultSet = st.execute(startID,endID)
            df = resultSet.dataframe()
            
            # Load a pre-trained sentence transformer model. This model's output vectors are of size 384
            model = sentence_transformers.SentenceTransformer("/shared/model/")
            # Generate embeddings for all descriptions at once. Batch processing makes it faster
            embeddings = model.encode(df['description'].tolist(), normalize_embeddings=True)

            # Add the embeddings to the DataFrame
            df['vectordescription'] = embeddings.tolist()

            stmt = iris.sql.prepare("UPDATE ENCODER_Object.Codes SET VectorDescription = TO_VECTOR(?,DECIMAL) WHERE CodeId = ?")
            for index, row in df.iterrows():
                rs = stmt.execute(str(row['vectordescription']), row['codeid'])

    except Exception as err:
        return str(err)    
    return "Finished"
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
