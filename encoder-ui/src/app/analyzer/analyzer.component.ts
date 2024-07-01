import { Component } from '@angular/core';
import { UntypedFormControl, UntypedFormGroup, Validators } from '@angular/forms';
import { IrisService } from '../services/iris.service';

@Component({
  selector: 'app-analyzer',
  standalone: true,
  imports: [],
  templateUrl: './analyzer.component.html',
  styleUrl: './analyzer.component.scss'
})
export class AnalyzerComponent {

  constructor(private irisService: IrisService) {
    
  }

  public resultForm = new UntypedFormGroup({
    TextToAnalyze: new UntypedFormControl('', {nonNullable: true, validators: [Validators.required]})
  })

  get textToAnalyze() {
    return this.resultForm.get('TextToAnalyze');
  }

  onSubmit() {
    const textForm = {
      "Text": this.textToAnalyze?.value
    };

    this.irisService.analyzeText(textForm).subscribe({next: res =>{

    },
    error: err => {
      console.error(JSON.stringify(err));
    }
    })
  }
}
