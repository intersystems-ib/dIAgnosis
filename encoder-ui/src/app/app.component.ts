import { Component, TemplateRef, inject } from '@angular/core';
import { NgbOffcanvas } from '@ng-bootstrap/ng-bootstrap';
import { TranslocoService } from '@ngneat/transloco';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  
	title = 'encoder-ui';
  private offcanvasService = inject(NgbOffcanvas);
  selectLang = 'es';

  constructor(private translocoService: TranslocoService){
	this.selectLanguage()
  }
  open(content: TemplateRef<any>) {
		this.offcanvasService.open(content, { ariaLabelledBy: 'offcanvas-basic-title' }).result.then(
			(result) => {
				// this.closeResult = `Closed with: ${result}`;
			},
			(reason) => {
				// this.closeResult = `Dismissed ${this.getDismissReason(reason)}`;
			},
		);
	}

	selectLanguage(language: string = this.selectLang) {
		this.translocoService.setActiveLang( language );
	}
}
