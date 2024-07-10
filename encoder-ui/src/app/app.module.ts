import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';
import { NgbAccordionModule, NgbModule, NgbPaginationModule, NgbProgressbarModule, NgbTypeaheadModule } from '@ng-bootstrap/ng-bootstrap';
import { DiagnosisComponent } from './diagnosis/diagnosis.component';
import { HttpClientModule } from '@angular/common/http';
import { CodelistComponent } from './codelist/codelist.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { AnalyzerComponent } from './analyzer/analyzer.component';
import { AnalysishistoryComponent } from './analysishistory/analysishistory.component';

@NgModule({
  declarations: [
    AppComponent,
    DiagnosisComponent,
    CodelistComponent,
    AnalyzerComponent,
    AnalysishistoryComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    NgbModule,
    NgbPaginationModule,
    NgbProgressbarModule,
    NgbAccordionModule,
    NgbTypeaheadModule,
    ReactiveFormsModule,
    FormsModule,
    HttpClientModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
