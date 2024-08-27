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
    var textToProcess = this.textToAnalyze?.value.split(".").filter(Boolean);
    var piecedTextToProcess: any[] = [];
    for (var index in textToProcess){
      piecedTextToProcess = piecedTextToProcess.concat(textToProcess[index].split(","))
    }
    var forReading = 100/(piecedTextToProcess.length);
    this.totalReceived = 0;
    this.error = false;
    this.loading = true;
    var regex = /[.,;:¿?!¡]/g;
    this.textAndDiagnosticList = [];
    const rawText = {
      "Text": textOriginal
    };
    this.irisService.saveRawText(rawText).subscribe({next: raw => {
      this.totalReceived = (100%(piecedTextToProcess.length)) + 1;
      for (var index in piecedTextToProcess){
        if (piecedTextToProcess[index] !== "")
        {
          const textData = {
            "ID": raw.id,
            "Text": piecedTextToProcess[index],
            "Language": this.translocoService.getActiveLang()
          };
          this.irisService.analyzeText(textData).subscribe({next: resp =>{
            this.totalReceived += forReading;
            if (this.totalReceived >= 100){
              this.irisService.getAnalysisDetails(raw.id).subscribe({next: res => {
                if (res.length > 0){
                  this.diagnostics = this.diagnostics.concat(res);
                }
                this.diagnostics.forEach((diagnostic, indexDiag) => {              
                    let phrase: string = "";
                    const arrayRawText = diagnostic.RawText.split(" ")
                    if (arrayRawText.length > 1){
                      const matchValue = textOriginal.toLowerCase().replace(regex,"").match(new RegExp(arrayRawText[0] + "(.{0,100})" +arrayRawText[arrayRawText.length-1],"gi"));
                      if (matchValue) {
                        phrase = matchValue[0];
                      }  
                    }                  
                    else if (diagnostic.RawText.split(" ").length == 1){
                      const matchValue = textOriginal.toLowerCase().replace(regex,"").match(new RegExp(diagnostic.RawText, "gi"));
                      if (matchValue) {
                        phrase = matchValue[0];
                      }
                    }
                    var indexDiag = this.textAndDiagnosticList.findIndex(obj => obj.rawText == phrase);
                    const diagnosticEncoded: Diagnostic = {code: diagnostic.CodeId, description: diagnostic.Description, similarity: diagnostic.Similarity}
                    if (indexDiag == -1)
                    {
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
                },
                error: err => {
                  this.error = true;
                  this.loading = false;
                }});
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

  markDiagnosis(text: String) {
    var regex = /[.,;:¿?!¡\(\)-]/g;
    this.unmarkDiagnosis();
    var textHTML = this.textToAnalyze?.value;
    var phrase = "";
    var indexInit = 0;

    if (text.split(" ").length > 1){
      const matchValue = new RegExp(text.split(" ")[0].replace(regex," ") + "(.{0,100})" +text.split(" ")[text.split(" ").length-1].replace(regex," "),"gi").exec(textHTML.toLowerCase().replace(regex," "));
      if (matchValue) {
        phrase = matchValue[0];
        indexInit = matchValue.index;
      }
    }    
    else if (text.split(" ").length == 1){
      const matchValue = new RegExp(text.replace(regex," "),"gi").exec(textHTML.toLowerCase().replace(regex," "));
      if (matchValue) {
        phrase = matchValue[0];
        indexInit = matchValue.index;
      }
    }

    textHTML = textHTML.replace(textHTML.substring(indexInit,indexInit+phrase.length), "<mark>"+textHTML.substring(indexInit,indexInit+phrase.length)+"</mark>");
    this.textUpdated = textHTML;
  }

  unmarkDiagnosis() {
    var textHTML = this.textToAnalyze?.value;
    textHTML = textHTML.replace("<mark>","");
    textHTML = textHTML.replace("</mark>","");
    this.textUpdated = textHTML;
  }
}
