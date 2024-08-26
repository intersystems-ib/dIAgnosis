import { Component, OnInit } from '@angular/core';
import { IrisService } from '../services/iris.service';

interface Diagnostic {
  code: String;
  description: String;
  similarity: number;
}

interface TextAndDiagnostic {
  rawText: string;
  diagnostics: Array<Diagnostic>;
}

interface AnalysisText {
  RawText: string;
  AnalysisDate: Date;
  Id: string;
}

@Component({
  selector: 'app-analysis',
  templateUrl: './analysis.component.html',
  styleUrl: './analysis.component.scss'
})
export class AnalysisComponent implements OnInit{

  textUpdated: String = "";
  diagnostics: Array<any> = [];
  loading = false;
  loadingMain = false;
  error = false;
  textAndDiagnosticList: Array<TextAndDiagnostic> = [];
  analysis: Array<AnalysisText> = [];
  analysisResult: Array<AnalysisText> = [];
  page = 1;
  pageSize = 5;
  collectionSize = 0;
  textOriginal: string = "";
  screenHeight: number = 0;
  textToMark: String = "";

  constructor(private irisService: IrisService) 
  {

  }

  ngOnInit(): void {
    this.screenHeight = window.innerHeight;
    if (this.screenHeight < 900) {
      this.pageSize = 5
    }
    else if (this.screenHeight > 900 && this.screenHeight < 1200 ) {
      this.pageSize = 7
    }
    else {
      this.pageSize = 10
    }

    this.loadHistory();
  }

  loadHistory() {
    this.loadingMain = true;
    this.irisService.getAnalysis().subscribe({next: record => {
      this.analysisResult = this.analysis.concat(record);
      this.collectionSize = this.analysisResult.length;
      this.refreshOptions();
      this.loadingMain = false;
    },
    error: err => {}
  });
  }

  refreshOptions() {
		this.analysis = this.analysisResult.map((option, i) => ({ id: i + 1, ...option })).slice(
			(this.page - 1) * this.pageSize,
			(this.page - 1) * this.pageSize + this.pageSize,
		);
	}

  analysisSelected(idAnalysis: string, textSelected: string) {
    this.diagnostics = [];
    this.textAndDiagnosticList = [];
    var textHTML = textSelected;
    this.textToMark = textSelected;
    this.loading = true;
    var regex = /[.,;:¿?!¡]/g;

    this.irisService.getAnalysisDetails(idAnalysis).subscribe({next: res => {
    if (res.length > 0){
      this.diagnostics = this.diagnostics.concat(res);
    }
    this.diagnostics.forEach((diagnostic, indexDiag) => {              
        let phrase: string = "";
        if (diagnostic.RawText.split(" ").length == 3){
          const matchValue = textSelected.toLowerCase().replace(regex,"").match(new RegExp(diagnostic.RawText.split(" ")[0] + "(.{0,100})" +diagnostic.RawText.split(" ")[2],"gi"));
          if (matchValue) {
            phrase = matchValue[0];
          }
        }
        else if (diagnostic.RawText.split(" ").length == 2){
          const matchValue = textSelected.toLowerCase().replace(regex,"").match(new RegExp(diagnostic.RawText.split(" ")[0] + "(.{0,100})" +diagnostic.RawText.split(" ")[1],"gi"));
          if (matchValue) {
            phrase = matchValue[0];
          }
        }
        else if (diagnostic.RawText.split(" ").length == 4){
          const matchValue = textSelected.toLowerCase().replace(regex,"").match(new RegExp(diagnostic.RawText.split(" ")[0] + "(.{0,100})" +diagnostic.RawText.split(" ")[3],"gi"));
          if (matchValue) {
            phrase = matchValue[0];
          }
        }
        else if (diagnostic.RawText.split(" ").length == 1){
          const matchValue = textSelected.toLowerCase().replace(regex,"").match(new RegExp(diagnostic.RawText,"gi"));
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
    }})
  }

  markDiagnosis(text: string) {
    this.unmarkDiagnosis();
    var textHTML = this.textToMark;
    const matchPhrase = this.textToMark.match(new RegExp(text,"ig"))
    if (matchPhrase){
      textHTML = textHTML.replace(matchPhrase[0],"<mark>"+matchPhrase[0]+"</mark>");
    }      
    this.textUpdated = textHTML;
  }

  unmarkDiagnosis() {
    var textHTML = this.textToMark;
    textHTML = textHTML.replace("<mark>","");
    textHTML = textHTML.replace("</mark>","");
    this.textUpdated = textHTML;
  }
}
