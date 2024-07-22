import { Component } from '@angular/core';
import { IrisService } from '../services/iris.service';
import { Subscription, switchMap, timer } from 'rxjs';

@Component({
  selector: 'app-loader',
  templateUrl: './loader.component.html',
  styleUrl: './loader.component.scss'
})
export class LoaderComponent {

  error = false;
  recordsSaved = 0;
  recordsVectorized = 0;
  percentageVectorized = 0;
  subscription !: Subscription;
  loading = false;

  constructor(private irisService: IrisService) 
  {
    this.getVectorizationInfo();
  }

  onFileChange(event: any) {
    const file = event.target.files[0];
    const reader = new FileReader();

    reader.onloadend = () => {
      const base64String = reader.result as string;
      const csvFile = {
        "File": base64String.split(",")[1]
      };
      this.irisService.saveCodesFile(csvFile).subscribe({next: raw => {
        this.getVectorizationInfo();
      },
      error: err => {
        this.error = true;
      }
    })
    };

    if (file) {
      reader.readAsDataURL(file);
    }
  }

  getVectorizationInfo() {
    this.irisService.getVectorizationInfo().subscribe({next: raw => {
      this.recordsSaved = raw.TotalRecords;
      this.recordsVectorized = raw.VectorizedRecords;
      this.loading = true;
      if (this.recordsSaved > 0) {
        this.percentageVectorized = (this.recordsVectorized/this.recordsSaved)*100;
        this.subscription = timer(0, 5000).pipe(
          switchMap(() => this.irisService.getVectorizationInfo())
        ).subscribe(result => {
          this.recordsSaved = result.TotalRecords;
          this.recordsVectorized = result.VectorizedRecords;
          if (result.TotalRecords == result.VectorizedRecords){
            this.percentageVectorized = 100;
            this.subscription.unsubscribe();
            this.loading = false;
          }
          else {
            this.percentageVectorized = (this.recordsVectorized/this.recordsSaved)*100;
          }      
        }
        );
      }
      else {
        this.loading = false;
      }
    },
    error: err => {
      this.error = true;
    }
  })
  }
}
