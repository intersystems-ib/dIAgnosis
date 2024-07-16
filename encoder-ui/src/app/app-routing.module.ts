import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { DiagnosisComponent } from './diagnosis/diagnosis.component';
import { AnalyzerComponent } from './analyzer/analyzer.component';
import { AnalysisComponent } from './analysis/analysis.component';

const routes: Routes = [
  { path: '', component: DiagnosisComponent },
  { path: 'analyzer', component: AnalyzerComponent },
  { path: 'analysis', component: AnalysisComponent },

];

@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    RouterModule.forRoot(routes)
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }
