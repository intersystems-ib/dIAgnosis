Class ENCODER.BP.CodeImportProcess Extends Ens.BusinessProcess
{

Method OnRequest(pInput As ENCODER.Message.GenericRequest, Output pOutput As ENCODER.Message.GenericResponse) As %Status
{
        set result = ""
        &sql(SELECT COUNT(*) INTO :totalRows FROM ENCODER_Object.Codes)
        if (SQLCODE = 0 && totalRows > 0)
        {
            set result = ..FinishCIE10()
        }
        else {
            set result = ..ParseCIE10(pInput.FilePath, pInput.CodeType)
        }
        set pOutput = ##class(ENCODER.Message.GenericResponse).%New()
        set pOutput.Result = result
        return $$$OK
}

Method ParseCIE10(filePath As %String, codeType As %String) As %String [ Language = python ]
{
    import csv
    import os
    import iris
    import pandas as pd
    import sentence_transformers

    try :
        if not os.path.isdir('/iris-shared/model/'):
            model = sentence_transformers.SentenceTransformer('FremyCompany/BioLORD-2023-M')            
            model.save('/iris-shared/model/')
        
        stmt = iris.sql.prepare("TRUNCATE TABLE ENCODER_Object.Codes")
        rs = stmt.execute()

        with open(filePath, "r",  encoding="utf-8") as csvfile:
            reader = csv.reader(csvfile, delimiter = ";")
            for row in reader:                
                stmt = iris.sql.prepare("INSERT INTO ENCODER_Object.Codes (CodeId, Description, CodeType) VALUES (?,?,?)")
                rs = stmt.execute(str(row[0]), row[1],codeType)
        flagLoop = True
        while flagLoop:
            st = iris.sql.prepare("SELECT TOP 50 CodeId, Description FROM ENCODER_Object.Codes WHERE VectorDescription is null ORDER BY ID ASC ")
            resultSet = st.execute()
            df = resultSet.dataframe()
            
            if (df.size > 0):
                model = sentence_transformers.SentenceTransformer("/iris-shared/model/")
                embeddings = model.encode(df['description'].tolist(), normalize_embeddings=True)

                df['vectordescription'] = embeddings.tolist()

                stmt = iris.sql.prepare("UPDATE ENCODER_Object.Codes SET VectorDescription = TO_VECTOR(?,DECIMAL) WHERE CodeId = ?")
                for index, row in df.iterrows():
                    rs = stmt.execute(str(row['vectordescription']), row['codeid'])
            else:
                flagLoop = False

    except Exception as err:
        return str(err)    
    return "Finished"
}

Method FinishCIE10() As %String [ Language = python ]
{
    import csv
    import os
    import iris
    import pandas as pd
    import sentence_transformers

    try :
        if not os.path.isdir('/iris-shared/model/'):
            model = sentence_transformers.SentenceTransformer('FremyCompany/BioLORD-2023-M')            
            model.save('/iris-shared/model/')
        
        flagLoop = True
        while flagLoop:
            st = iris.sql.prepare("SELECT TOP 50 CodeId, Description FROM ENCODER_Object.Codes WHERE VectorDescription is null ORDER BY ID ASC ")
            resultSet = st.execute()
            df = resultSet.dataframe()
            
            if (df.size > 0):
                model = sentence_transformers.SentenceTransformer("/iris-shared/model/")
                embeddings = model.encode(df['description'].tolist(), normalize_embeddings=True)

                df['vectordescription'] = embeddings.tolist()

                stmt = iris.sql.prepare("UPDATE ENCODER_Object.Codes SET VectorDescription = TO_VECTOR(?,DECIMAL) WHERE CodeId = ?")
                for index, row in df.iterrows():
                    rs = stmt.execute(str(row['vectordescription']), row['codeid'])
            else:
                flagLoop = False

    except Exception as err:
        return str(err)    
    return "Finished"
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
