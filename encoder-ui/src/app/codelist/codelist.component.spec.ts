import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CodelistComponent } from './codelist.component';

describe('CodelistComponent', () => {
  let component: CodelistComponent;
  let fixture: ComponentFixture<CodelistComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CodelistComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(CodelistComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
