import { Component } from '@angular/core';
import { UntypedFormControl, UntypedFormGroup, Validators } from '@angular/forms';
import { IrisService } from '../services/iris.service';
import { TranslocoService } from '@ngneat/transloco';

interface Diagnostic {
  code: String;
  description: String;
  similarity: number;
}

interface TextAndDiagnostic {
  rawText: String;
  diagnostics: Array<Diagnostic>;
}

@Component({
  selector: 'app-analyzer',
  templateUrl: './analyzer.component.html',
  styleUrl: './analyzer.component.scss'
})

export class AnalyzerComponent {

  textUpdated = "";
  diagnostics: Array<any> = [];
  loading = false;
  error = false;
  totalReceived = 0;
  textAndDiagnosticList: Array<TextAndDiagnostic> = [];

  constructor(private irisService: IrisService,
    private translocoService: TranslocoService
  ) 
  {
    
  }

  public textForm = new UntypedFormGroup({
    TextToAnalyze: new UntypedFormControl('', {nonNullable: true, validators: [Validators.required]})
  })

  get textToAnalyze() {
    return this.textForm.get('TextToAnalyze');
  }

  onSubmit() {
    this.diagnostics = [];
    var textHTML = this.textToAnalyze?.value;
    var textOriginal = textHTML;
    var textToProcess = this.textToAnalyze?.value.split(".");
    var forReading = 100/(textToProcess.length-1);
    this.totalReceived = 0;
    this.error = false;
    this.loading = true;
    this.textAndDiagnosticList = [];
    const rawText = {
      "Text": textOriginal
    };
    this.irisService.saveRawText(rawText).subscribe({next: raw => {
      this.totalReceived = 5
      for (var index in textToProcess){
        if (textToProcess[index] !== "")
        {
          const textData = {
            "ID": raw.id,
            "Text": textToProcess[index],
            "Language": this.translocoService.getActiveLang()
          };
          this.irisService.analyzeText(textData).subscribe({next: res =>{
            if (res.length > 0){
              this.diagnostics = this.diagnostics.concat(res);
            }
            this.totalReceived += forReading;
            if (this.totalReceived >= 100){
              this.diagnostics.forEach((diagnostic, indexDiag) => {              
                let phrase = "";
                if (diagnostic.RawText.split(" ").length == 3){
                  phrase = textOriginal.match(new RegExp(diagnostic.RawText.split(" ")[0] + " (.{0,100}) " +diagnostic.RawText.split(" ")[2],"ig"))[0];
                }
                else if (diagnostic.RawText.split(" ").length == 2){
                  phrase = textOriginal.match(new RegExp(diagnostic.RawText.split(" ")[0] + " (.{0,100}) " +diagnostic.RawText.split(" ")[1],"ig"))[0];
                }
                else if (diagnostic.RawText.split(" ").length == 4){
                  phrase = textOriginal.match(new RegExp(diagnostic.RawText.split(" ")[0] + " (.{0,100}) " +diagnostic.RawText.split(" ")[3],"ig"))[0];
                }
                else if (diagnostic.RawText.split(" ").length == 1){
                  phrase = textOriginal.match(diagnostic.RawText);
                }
                var indexDiag = this.textAndDiagnosticList.findIndex(obj => obj.rawText == phrase);
                const diagnosticEncoded: Diagnostic = {code: diagnostic.CodeId, description: diagnostic.Description, similarity: diagnostic.Similarity}
                if (indexDiag == -1)
                {
                  textHTML = textHTML.replace(phrase,"<mark>"+phrase+"</mark>");
                  let textAndDiagnostic: TextAndDiagnostic = {rawText: phrase, diagnostics: []};
                  textAndDiagnostic.diagnostics.push(diagnosticEncoded);
                  this.textAndDiagnosticList.push(textAndDiagnostic);
                }
                else {
                  this.textAndDiagnosticList[indexDiag].diagnostics.push(diagnosticEncoded)
                }                           
              })
              this.textUpdated = textHTML
              this.loading = false;
            }
          },
          error: err => {
            this.error = true;
            this.loading = false;
          }
          }); 
        }
      }
    },
    error: err => {
      this.error = true;
      this.loading = false;
    }});  
}

  createAlert() {
    alert("Es un diagnóstico");
  }
}
