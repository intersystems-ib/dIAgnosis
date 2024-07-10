import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AnalysishistoryComponent } from './analysishistory.component';

describe('AnalysishistoryComponent', () => {
  let component: AnalysishistoryComponent;
  let fixture: ComponentFixture<AnalysishistoryComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AnalysishistoryComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(AnalysishistoryComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
