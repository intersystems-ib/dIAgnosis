import { Component } from '@angular/core';
import { ReactiveFormsModule, UntypedFormControl, UntypedFormGroup, Validators } from '@angular/forms';
import { IrisService } from '../services/iris.service';

@Component({
  selector: 'app-analyzer',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './analyzer.component.html',
  styleUrl: './analyzer.component.scss'
})
export class AnalyzerComponent {

  textUpdated = "";
  diagnostics: Array<any> = []

  constructor(private irisService: IrisService) {
    
  }

  public textForm = new UntypedFormGroup({
    TextToAnalyze: new UntypedFormControl('', {nonNullable: true, validators: [Validators.required]})
  })

  get textToAnalyze() {
    return this.textForm.get('TextToAnalyze');
  }

  onSubmit() {
    const textData = {
      "Text": this.textToAnalyze?.value
    };
    var textHTML = this.textToAnalyze?.value;

    this.irisService.analyzeText(textData).subscribe({next: res =>{
      this.diagnostics = res;
      this.diagnostics.forEach((diagnostic) => {
        const phrase = textHTML.match(new RegExp(diagnostic.RawText.split(" ")[0] + "(.*)" +diagnostic.RawText.split(" ")[2],"ig"))[0];
          textHTML = textHTML.replace(phrase,"<mark>"+phrase+"</mark>");
      })
      this.textUpdated = textHTML
    },
    error: err => {
      console.error(JSON.stringify(err));
    }
    })
  }

  createAlert() {
    alert("Es un diagnóstico");
  }
}
