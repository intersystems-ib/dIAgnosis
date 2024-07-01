import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

const IRIS_API = 'api/encoder/';

let httpOptions = {
  headers: new HttpHeaders({ 'Content-Type': 'application/json' })
};

@Injectable({
  providedIn: 'root'
})
export class IrisService {

  constructor(private http: HttpClient) { }

  getCodeRequests(): Observable<any> {
    return this.http.get<Response>(
      IRIS_API + 'getCodeRequests', httpOptions
    )
  }

  getCodeOptions(codeRequestId: String): Observable<any> {
    return this.http.get<Response>(
      IRIS_API + 'getCodeOptions/'+codeRequestId, httpOptions
    )
  }

  saveCodification(codification: any): Observable<any> {
    return this.http.post<Response>(
      IRIS_API + 'saveCodification',codification
    )
  }

  sendNotification(notification: any): Observable<any> {
    return this.http.post<Response>(
      IRIS_API + 'sendNotification', notification
    )
  }

  analyzeText(text: any): Observable<any> {
    return this.http.post<Response>(
      IRIS_API + 'analyzeText',text
    )
  }
}
