import { Component, OnInit, TemplateRef, inject } from '@angular/core';
import { IrisService } from '../services/iris.service';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';

@Component({
  selector: 'app-diagnosis',
  templateUrl: './diagnosis.component.html',
  styleUrls: ['./diagnosis.component.scss']
})
export class DiagnosisComponent implements OnInit {

  private modalService = inject(NgbModal);
  codeRequests: Array<any> = [];
  codeRequestsResult: Array<any> = [];
  codeRequestId: string = "";
  codeRequestDescription: string = "";
  page = 1;
  pageSize = 10;
  collectionSize = 0;
  loading = true;
  screenHeight: number = 0;

  constructor(private irisService: IrisService) {
    
  }

  ngOnInit() {
    this.screenHeight = window.innerHeight;
    if (this.screenHeight < 900) {
      this.pageSize = 10
    }
    else if (this.screenHeight > 900 && this.screenHeight < 1200 ) {
      this.pageSize = 15
    }
    else {
      this.pageSize = 20
    }

    this.loadRequests()
  }

  loadRequests(): void {
    this.loading = true;
    this.irisService.getCodeRequests().subscribe({
      next: res => {  
        this.codeRequestsResult = res;
        this.collectionSize = this.codeRequestsResult.length;
        this.refreshRequests();
        this.loading = false;
      },
      error: err => {
        console.error(JSON.stringify(err));
      }
    });
  }

  open(content: TemplateRef<any>, codeId: string, description: string) {
    this.codeRequestId = codeId;
    this.codeRequestDescription = description;
		this.modalService.open(content, { ariaLabelledBy: 'modal-basic-title', size: 'xl' }).result.then(
			(result) => {
			},
			(reason) => {

			},
		);
	}

  refreshRequests() {
		this.codeRequests = this.codeRequestsResult.map((request, i) => ({ id: i + 1, ...request })).slice(
			(this.page - 1) * this.pageSize,
			(this.page - 1) * this.pageSize + this.pageSize,
		);
	}

  sendNotification(codeRequestId: number) {
    const notification = {
      "CodeRequestId": codeRequestId, 
    };
    this.irisService.sendNotification(notification).subscribe({
      next: res => {  
        
      },
      error: err => {
        console.error(JSON.stringify(err));
      }
    });
  }
}
