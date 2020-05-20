import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from "prop-types"

// ランダムに配列をシャッフル
const nativeShuffle = ([...array]) => {
  for (let i = array.length - 1; i >= 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}

// シャッフルした配列を一時的に保存しておく
var latestArray;

//選択肢
function Choice (props) {
  return (
    <React.Fragment>
      <button onClick={() => props.onClick(props.answer, props.choice)}>{props.choice}</button>
    </React.Fragment>
  );
}

// 正誤結果表示
function Correctness (props) {
  if (props.collectness) {
    return (<div>正解!</div>);
  } else {
    return (<div>不正解...</div>);
  }
}

// 次へボタン
function NextButton (props) {
  return (  
    <React.Fragment>
      <button onClick={props.onClick}>次へ</button>
    </React.Fragment>
  );
}

// 最終結果画面
function Result (props) {
  return (
    <React.Fragment>
      <div>終了</div>
      <a href='/'>トップに戻る</a>
    </React.Fragment>
  );
}

// 4択フィールドを管理
class Question extends React.Component {
  // データを受け取り、4択を生成する
  renderChoice (choice) {
    return (
      <div>
        <Choice
        answer={this.props.question.answer}
        choice={choice}
        onClick={(a, c) => this.props.onClick(a, c)}
        />
      </div>
    );
  }

  render() {
    // 分岐が行われているのは回答画面表示時に選択肢の位置が変わってしまわないようにするため
    var choices;
    if (this.props.answering) {
      choices = nativeShuffle([
        this.props.question.answer,
        this.props.question.wrong1,
        this.props.question.wrong2,
        this.props.question.wrong3
      ]);
      latestArray = choices;
    } else {
      choices = latestArray;
    }

    return (
      <div>
        <div>Q.{this.props.number + 1} {this.props.question.sentence}</div>
        <div>{this.renderChoice(choices[0])}</div>
        <div>{this.renderChoice(choices[1])}</div>
        <div>{this.renderChoice(choices[2])}</div>
        <div>{this.renderChoice(choices[3])}</div>
      </div>
    );
  };
}


class Course extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      // 問題情報
      questions: nativeShuffle(this.props.questions),
      // 何問目か
      number: 0,
      // 回答中?
      answering: true,
      // 最後の一問?
      lastQuestion: false,
      // 全問おわった?
      allFinished: false,
      // 直前の問題を正解したか
      lastestResult: null,
      // 回答履歴
      history: [],
    };
  }
  
  // 選択肢をクリックした時の操作
  clickChoice (answer, choice) {
    if (this.state.answering) {
      if (answer === choice) {
        this.setState({lastestResult: true});
      } else {
        this.setState({lastestResult: false});
      }
      // 回答中をfalseにする
      this.setState({
        answering: false,
        history: this.state.history.concat(answer === choice)
      });
    } else {
      return;
    }
  }

  // 次へボタンをクリックした時の操作
  clickNext () {
    if (this.state.questions.length === this.state.number + 1) {
      this.setState({lastQuestion: true});
    }
    this.setState({
      answering: true,
      number: this.state.number + 1,
    })
  }
  
  render() {
    const number = this.state.number;
    const question = this.state.questions[number];
    const answering = this.state.answering;
    const lastQuestion = this.state.lastQuestion;
    const lastestResult = this.state.lastestResult;
    const history = this.state.history;
    
    const answered = () => {
      return (
        <div>
          <Correctness
          collectness={lastestResult}
          />
          <div>{question.commentary}</div>
          <NextButton 
          onClick={() => this.clickNext()}
          />
        </div>
      );
    }
    
    const setQuestion = () => {
      return (
        <Question
        question={question}
        number={number}
        answering={answering}
        onClick={(a, c) => this.clickChoice(a, c)}
        />
      );
    }

    const setHistory = history.map((value, i) => {
      var number = i + 1;
      var correctness = value ? "O" : "X";
      return(
        <div key={number}>Q{number}. {correctness}</div>
      );
    });

    const generatePage = (answering, question) => {
      if (this.state.lastQuestion) {
        return(
          <Result />
        );
      } else if (answering) {
        return setQuestion(question);
      } else {
        return (
          <div>
            {setQuestion(question)}
            {answered(question)}
          </div>
        );
      }
    };

    return (
      <div>
        {generatePage(answering, question, lastQuestion)}
        {setHistory}
      </div>
    );
  }
}

Course.propTypes = {
  questions: PropTypes.array
}
export default Course