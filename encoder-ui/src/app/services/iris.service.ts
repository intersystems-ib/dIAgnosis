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

  saveRawText(text: any): Observable<any> {
    return this.http.post<Response>(
      IRIS_API + 'saveRawText',text
    )
  }

  getTextAnalyzed(analysisId: String): Observable<any> {
    return this.http.get<Response>(
      IRIS_API + 'getAnalyzedText/'+analysisId
    )
  }

  getAnalysis(): Observable<any> {
    return this.http.get<Response>(
      IRIS_API + 'getAnalysis'
    )
  }

  getAnalysisDetails(analysisId: String): Observable<any> {
    return this.http.get<Response>(
      IRIS_API + 'getAnalysisDetails/'+analysisId
    )
  }

  saveCodesFile(file: any): Observable<any> {
    return this.http.post<Response>(
      IRIS_API + 'saveCodeFile',file
    )
  }

  getVectorizationInfo(): Observable<any> {
    return this.http.get<Response>(
      IRIS_API + 'getVectorizationInfo'
    )
  }
}
