import { TestBed } from '@angular/core/testing';

import { FutureorderService } from './futureorder.service';

describe('FutureorderService', () => {
  let service: FutureorderService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(FutureorderService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
