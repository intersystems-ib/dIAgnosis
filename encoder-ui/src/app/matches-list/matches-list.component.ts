import { Component, EventEmitter, Input, OnChanges, Output, SimpleChanges } from '@angular/core';

interface Diagnostic {
  code: String;
  description: String;
  similarity: number;
}

@Component({
  selector: 'app-matches-list',
  templateUrl: './matches-list.component.html',
  styleUrl: './matches-list.component.scss'
})

export class MatchesListComponent implements OnChanges{

  @Input() diagnostics: Array<Diagnostic> = [];
  @Output() newCodeEvent = new EventEmitter<any>();
  

  diagnosticsPage: Array<Diagnostic> = [];
  loading = true;
  page = 1;
  pageSize = 10;
  collectionSize = 0;

  constructor() {
    
  }

  ngOnChanges(changes: SimpleChanges): void {
      this.loadPage();
  }
  
  loadPage(): void {
    this.collectionSize = this.diagnostics.length;
    this.refreshOptions();
    this.loading = false;
    
  }  

  refreshOptions() {
		this.diagnosticsPage = this.diagnostics.map((option, i) => ({ id: i + 1, ...option })).slice(
			(this.page - 1) * this.pageSize,
			(this.page - 1) * this.pageSize + this.pageSize,
		);
	}

}