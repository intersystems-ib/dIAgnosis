import { Component } from '@angular/core';
import { IrisService } from '../services/iris.service';

@Component({
  selector: 'app-loader',
  templateUrl: './loader.component.html',
  styleUrl: './loader.component.scss'
})
export class LoaderComponent {

  error = false;
  loading = false;

  constructor(private irisService: IrisService) 
  {
    
  }

  onFileChange(event: any) {
    const file = event.target.files[0];
    const reader = new FileReader();

    reader.onloadend = () => {
      const base64String = reader.result as string;
      const csvFile = {
        "File": base64String
      };
      this.irisService.saveRawText(csvFile).subscribe({next: raw => {

      },
      error: err => {
        this.error = true;
        this.loading = false;
      }
    })
    };

    if (file) {
      reader.readAsDataURL(file);
    }
  }
}
