import { Component, EventEmitter, Input, OnChanges, OnInit, Output, SimpleChanges } from '@angular/core';
import { IrisService } from '../services/iris.service';

@Component({
  selector: 'app-codelist',
  templateUrl: './codelist.component.html',
  styleUrl: './codelist.component.scss'
})
export class CodelistComponent implements OnChanges {

  @Input() codeRequestId: string = "";
  @Output() newCodeEvent = new EventEmitter<any>();

  codeOptions: Array<any> = [];
  codeOptionsResult: Array<any> = [];
  loading = true;
  page = 1;
  pageSize = 10;
  collectionSize = 0;

  constructor(private irisService: IrisService) {
    
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (this.codeRequestId !== "") {
      this.loadCodes();
    }
  }
  
  loadCodes(): void {
    this.irisService.getCodeOptions(this.codeRequestId).subscribe({
      next: res => {  
        this.codeOptionsResult = res;
        this.collectionSize = this.codeOptionsResult.length;
        this.refreshOptions();
        this.loading = false;
      },
      error: err => {
        console.error(JSON.stringify(err));
      }
    });
  }

  saveCodification(code: string): void {
    const codification = {
      "CodeRequestId": this.codeRequestId, 
      "Code": code 
    };
    this.irisService.saveCodification(codification).subscribe({
      next: res => {
        this.newCodeEvent.emit();
      },
      error: err => {
        console.error(JSON.stringify(err));
      }
    });
  }

  refreshOptions() {
		this.codeOptions = this.codeOptionsResult.map((option, i) => ({ id: i + 1, ...option })).slice(
			(this.page - 1) * this.pageSize,
			(this.page - 1) * this.pageSize + this.pageSize,
		);
	}

}
