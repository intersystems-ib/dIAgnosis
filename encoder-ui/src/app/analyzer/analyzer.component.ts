import { Component, inject, TemplateRef } from '@angular/core';
import { UntypedFormControl, UntypedFormGroup, Validators } from '@angular/forms';
import { IrisService } from '../services/iris.service';
import { TranslocoService } from '@ngneat/transloco';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';

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

  private modalService = inject(NgbModal);
  textUpdated = "";
  diagnostics: Array<any> = [];
  loading = false;
  error = false;
  totalReceived = 0;
  textAndDiagnosticList: Array<TextAndDiagnostic> = [];
  diagnosticsSelected: Array<Diagnostic> = [];
  diagnosticText: String = "";

  constructor(private irisService: IrisService,
    private translocoService: TranslocoService
  ) 
  {
    
  }

  public textForm = new UntypedFormGroup({
    TextToAnalyze: new UntypedFormControl('', {nonNullable: true, validators: [Validators.required]}),
    UseLLM: new UntypedFormControl('', {nonNullable: false, validators: [Validators.required]})
  })

  get textToAnalyze() {
    return this.textForm.get('TextToAnalyze');
  }

  get useLLM() {
    return this.textForm.get('UseLLM');
  }

  onSubmit() {
    this.diagnostics = [];
    var textHTML = this.textToAnalyze?.value;
    var textOriginal = textHTML;
    var llmEnabled = this.useLLM?.value;
    var textToProcess = [];
    var piecedTextToProcess: any[] = [];

    if (llmEnabled) {
      piecedTextToProcess = [textOriginal]
    }
    else {
      textToProcess = this.textToAnalyze?.value.split(".").filter(Boolean);
      for (var index in textToProcess){
        piecedTextToProcess = piecedTextToProcess.concat(textToProcess[index].split(","))
      }
    }
    
    var forReading = 100/(piecedTextToProcess.length);
    this.totalReceived = 0;
    this.error = false;
    this.loading = true;
    this.textAndDiagnosticList = [];
    const rawText = {
      "Text": textOriginal,
    };
    this.irisService.saveRawText(rawText).subscribe({next: raw => {
      this.totalReceived = 0;
      for (var index in piecedTextToProcess){
        if (piecedTextToProcess[index] !== "")
        {
          const textData = {
            "ID": raw.id,
            "Text": piecedTextToProcess[index],
            "Language": this.translocoService.getActiveLang(),
            "UseLLM": llmEnabled
          };
          this.irisService.analyzeText(textData).subscribe({next: resp =>{
            this.totalReceived += forReading;
            if (this.totalReceived >= 100){
              this.irisService.getAnalysisDetails(raw.id).subscribe({next: res => {
                if (res.length > 0){
                  this.diagnostics = this.diagnostics.concat(res);
                }
                this.diagnostics.forEach((diagnostic, indexDiag) => {
                    var indexDiag = this.textAndDiagnosticList.findIndex(obj => obj.rawText == diagnostic.RawText);
                    const diagnosticEncoded: Diagnostic = {code: diagnostic.CodeId, description: diagnostic.Description, similarity: diagnostic.Similarity}
                    if (indexDiag == -1)
                    {
                      let textAndDiagnostic: TextAndDiagnostic = {rawText: diagnostic.RawText, diagnostics: []};
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
    var regEx = new RegExp(text.trim(), "ig");
    this.unmarkDiagnosis();
    var textHTML = this.textToAnalyze?.value;

    textHTML = textHTML.replace(regEx, "<mark>"+text+"</mark>");
    this.textUpdated = textHTML;
  }

  unmarkDiagnosis() {
    var textHTML = this.textToAnalyze?.value;
    textHTML = textHTML.replace("<mark>","");
    textHTML = textHTML.replace("</mark>","");
    this.textUpdated = textHTML;
  }

  open(content: TemplateRef<any>, textAndDiagnostic: TextAndDiagnostic) {
    this.diagnosticText = textAndDiagnostic.rawText;
    this.diagnosticsSelected = textAndDiagnostic.diagnostics;
		this.modalService.open(content, { ariaLabelledBy: 'modal-basic-title', size: 'xl' }).result.then(
			(result) => {
			},
			(reason) => {

			},
		);
	}
}
