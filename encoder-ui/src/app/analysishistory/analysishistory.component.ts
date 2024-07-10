import { Component } from '@angular/core';
import { IrisService } from '../services/iris.service';

interface Diagnostic {
  code: String;
  description: String;
  similarity: number;
}

interface TextAndDiagnostic {
  rawText: String;
  diagnostics: Array<Diagnostic>;
}

interface AnalysisText {
  analysisText: String;
  analysisDate: Date;
}

@Component({
  selector: 'app-analysishistory',
  templateUrl: './analysishistory.component.html',
  styleUrl: './analysishistory.component.scss'
})
export class AnalysishistoryComponent {

  textUpdated = "";
  diagnostics: Array<any> = [];
  loading = false;
  error = false;
  totalReceived = 0;
  textAndDiagnosticList: Array<TextAndDiagnostic> = [];
  analysis: Array<AnalysisText> = [];

  constructor(private irisService: IrisService) 
  {
    
  }

  loadHistory() {
    this.irisService.getAnalysis().subscribe({next: record => {
      this.analysis.push(record);
    },
    error: err => {}
  });
  }
}
